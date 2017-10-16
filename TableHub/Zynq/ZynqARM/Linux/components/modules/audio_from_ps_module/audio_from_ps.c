/*
 *  File		            : generic_register.c
 *	AUTHOR : Andrea Albano
 *	mail		            : andrea.albano@bdsound.com
 *	bdSound	             	: www.bdsound.com
 */
//#error sdajdlfsjkdsflk
#include <linux/kernel.h> // printk()
#include <linux/module.h>
#include <linux/fs.h> // file system xface & registration
#include <asm/uaccess.h>	/* for put_user */
#include <linux/init.h> // module definition
#include <linux/slab.h>		/* kmalloc() */
#include <linux/sched.h>
#include <linux/errno.h> // error codes
#include <linux/delay.h>	/* udelay */
#include <linux/kdev_t.h> // major & minor, actually not used
#include <linux/ioport.h> // request/release_mem_region
#include <linux/interrupt.h> // tasklets & interrupts
#include <linux/wait.h> // sleeping
#include <asm/io.h> // mapping of physical memory
#include <linux/cdev.h> // device driver registration
#include <linux/ioctl.h> // ioctl
#include <linux/timer.h>
#include "xparameters.h"

#define KERNEL_BDSOUND
#define SUCCESS 0

#define DEVICE_NAME "audio_to_ps"

// imported from xparameters.h


#define MEM_BASE_ADDRESS 		XPAR_AUDIO_BRAM_CTRL_FROM_PS_S_AXI_BASEADDR
#define REG_BASE_ADDRESS		XPAR_AUDIO_AUDIO_FROM_PS_BASEADDR
#define AUDIO_FROM_PS_IRQ 			(XPAR_FABRIC_AUDIO_AUDIO_FROM_PS_INTR_INTR)

#define AUDIO_FROM_PS_MS_PER_BUF_MAX		10
#define AUDIO_FROM_PS_SAMPLE_FREQ			32000
#define AUDIO_FROM_PS_CH_NUM				4
#define AUDIO_FROM_PS_FRAME_PER_BUF_MAX		(AUDIO_FROM_PS_MS_PER_BUF_MAX*AUDIO_FROM_PS_SAMPLE_FREQ/1000)
#define AUDIO_FROM_PS_SAMPLE_PER_BUF_MAX	(AUDIO_FROM_PS_FRAME_PER_BUF_MAX*AUDIO_FROM_PS_CH_NUM)
#define AUDIO_FROM_PS_BUF_SIZE_MAX			(AUDIO_FROM_PS_SAMPLE_PER_BUF_MAX*4)
#define AUDIO_FROM_PS_MEM_SIZE				(AUDIO_FROM_PS_BUF_SIZE_MAX*2)


 

//#define REG1_SIZE				0x4000
static uint16_t audio_from_ps_size				=	AUDIO_FROM_PS_MEM_SIZE;
static uint16_t audio_from_ps_half_size			=	AUDIO_FROM_PS_BUF_SIZE_MAX;
static uint16_t audio_from_ps_sample_per_buffer	=	AUDIO_FROM_PS_SAMPLE_PER_BUF_MAX;


#define AUDIO_FROM_PS_OFF				(audio_from_ps_size<<16)
#define AUDIO_FROM_PS_ON				(AUDIO_FROM_PS_OFF|0x1)
#define AUDIO_FROM_PS_CLR_ON			(AUDIO_FROM_PS_ON|0x2)
#define AUDIO_FROM_PS_CLR_OFF			(AUDIO_FROM_PS_OFF|0x2)

#define AUDIO_FROM_PS_IOC_MAGIC 'z'
#define AUDIO_FROM_PS_IOC_MAXNR 2


#define AUDIO_FROM_PS_SET_BUF_LEN _IOW(AUDIO_FROM_PS_IOC_MAGIC,1,unsigned int)
#define AUDIO_FROM_PS_SET_ON_OFF _IOW(AUDIO_FROM_PS_IOC_MAGIC,2,unsigned int)





// device data
static int deviceOpenDesc = 0; // to prevent multiple access
volatile unsigned int *memBaseAddrPtr = NULL; // pointer to
volatile unsigned int *regBaseAddrPtr = NULL; // pointer to
static struct semaphore sync;
unsigned int *dataW;
static DECLARE_WAIT_QUEUE_HEAD(queue);

irqreturn_t audioFromPsIntHandler(int irq, void *dev_id);


static int audio_from_ps_flag = 0; 
static int audio_from_ps_position = 0;

static int running=0;



void audioFromPsTasklet(unsigned long unused);
DECLARE_TASKLET_DISABLED(audioFromPsDeviceTasklet,audioFromPsTasklet, 0);
// Interrupt handler: bottom half. A tasklet.
void audioFromPsTasklet(unsigned long unused) {

	// if(ioread32(&regBaseAddrPtr[0])&0x1)
		// printk(KERN_NOTICE"Interrupt not cleared");
	// else
	//printk(KERN_NOTICE"Interrupt cleared");

	//removing clear interrupt
	iowrite32(AUDIO_FROM_PS_ON, &regBaseAddrPtr[1]);
	audio_from_ps_position = (ioread32(&regBaseAddrPtr[0])>>1)&0x01;
    audio_from_ps_flag = 1;

    wake_up_interruptible(&queue);
}

// Interrupt handler: top half
irqreturn_t audioFromPsIntHandler(int irq, void *dev_id) 
{
	//clear interrupt
	iowrite32(AUDIO_FROM_PS_CLR_ON, &regBaseAddrPtr[1]);
    tasklet_schedule(&audioFromPsDeviceTasklet);
    return IRQ_HANDLED;
}

static long device_ioctl(struct file *filp, unsigned int cmd,unsigned long arg) {
	int result = SUCCESS;

    if (_IOC_TYPE(cmd) != AUDIO_FROM_PS_IOC_MAGIC) return -ENOTTY;
	if (_IOC_NR(cmd) > AUDIO_FROM_PS_IOC_MAXNR) return -ENOTTY;
    switch (cmd) {
        case AUDIO_FROM_PS_SET_BUF_LEN :
	    {
			
			if(arg>AUDIO_FROM_PS_MEM_SIZE)
			{	
				printk(KERN_NOTICE"[audio_from_ps] size out of range: try %d, max allowed %d\n",arg,AUDIO_FROM_PS_MEM_SIZE);
				return -EINVAL;
			}
			if(running==0)
			{
				audio_from_ps_size = arg;
				audio_from_ps_half_size = arg/2;
				audio_from_ps_sample_per_buffer = arg/8;
				iowrite32(AUDIO_FROM_PS_OFF, &regBaseAddrPtr[1]);
				printk(KERN_NOTICE"audio from ps size changed to %d\n",audio_from_ps_size);
			}
			else
			{
				printk(KERN_NOTICE"[audio_from_ps] running: can't change buffer size when running\n");
			}
			return SUCCESS;
	    }
	    case AUDIO_FROM_PS_SET_ON_OFF :
	    {
			if(arg==1)
			{
				if(running==1)
				{
					printk(KERN_NOTICE"[audio_from_ps]  aready running with size %d\n",audio_from_ps_size);
				}
				else
				{
					iowrite32(AUDIO_FROM_PS_ON, &regBaseAddrPtr[1]);

					tasklet_enable(&audioFromPsDeviceTasklet);
					result = request_irq(AUDIO_FROM_PS_IRQ, audioFromPsIntHandler,0, DEVICE_NAME, NULL);
					if (result) {
						printk(KERN_INFO "[audio_from_ps] %s: can't get irq assigned, error %d\n",DEVICE_NAME, result);
						deviceOpenDesc = 0;
						return -EIO;
					}

					printk(KERN_NOTICE"[audio_from_ps] started with size %d and irq num %d\n",audio_from_ps_size,AUDIO_FROM_PS_IRQ);

					running=1;


				}
			}
			else
			{
				if(running==0)
				{
					printk(KERN_NOTICE"[audio_from_ps] aready stopped\n");
				}
				else
				{
					iowrite32(AUDIO_FROM_PS_OFF, &regBaseAddrPtr[1]);

					free_irq(AUDIO_FROM_PS_IRQ, NULL);
					tasklet_disable(&audioFromPsDeviceTasklet);
					
					printk(KERN_NOTICE"[audio_from_ps] stopped\n");
					running=0;
				}
			}
	        return SUCCESS;
	    }
	    default:
	        return -ENOTTY;
    }
}

static ssize_t device_read(struct file *filp, char __user *buffer,size_t len, loff_t *off) {
	// int result = SUCCESS;
	// int i;
	// int pos;	
	
	// if(len>audio_from_ps_half_size)
	// {
		// printk(KERN_ALERT"Audio read invalid length: got %d while max is %d\n", len, audio_from_ps_half_size);
		// return -EINVAL;
	// }	
	// //printk(KERN_INFO "Read going to sleep\n");
    // wait_event_interruptible(queue, audio_from_ps_flag != 0);
    // audio_from_ps_flag = 0;
    // //printk(KERN_INFO "Read awoken\n");
	
	// if(audio_from_ps_position)
		// pos=0;
	// else
		// pos=1;
	// for(i=0; i<len/4; i++)	
	// {
		// dataR[i] = ioread32(&memBaseAddrPtr[i+pos*audio_from_ps_sample_per_buffer]);	
		// //printk(KERN_NOTICE"Data %d: 0x%d\n",i,((int *)dataR)[i]);
	// }
	// copy_to_user(buffer,dataR,len);
	return 0;
}




static ssize_t device_write(struct file *filp,const char __user *buffer,size_t len, loff_t *off) {
	unsigned int addr;
	int i;
	int pos;
	if(len>audio_from_ps_half_size)
	{
		printk(KERN_ALERT"[audio_from_ps] Audio write invalid length: got %d while max is %d\n", len, audio_from_ps_half_size);
		return -EINVAL;
	}	
	copy_from_user(dataW,buffer,len);
	
    //printk(KERN_DEBUG "Write going to sleep\n");
    wait_event_interruptible(queue, audio_from_ps_flag != 0);
    audio_from_ps_flag = 0;
    //printk(KERN_DEBUG "Write awoken\n");
	if(audio_from_ps_position)
		pos=0;
	else
		pos=1;
	for(i=0; i<len/4; i++)	
	{
		//printk(KERN_NOTICE"Data %d: %d\n",i,((int *)dataW)[i]);
		iowrite32(dataW[i], &memBaseAddrPtr[i+pos*audio_from_ps_sample_per_buffer]);
	}
	return len;
}
	

static int device_release(struct inode *inode, struct file *file) {
	int result;
    if (down_interruptible(&sync)){ 
	    return -ERESTARTSYS;
    }
	if(running ==1)
	{
		iowrite32(AUDIO_FROM_PS_OFF, &regBaseAddrPtr[1]);

		free_irq(AUDIO_FROM_PS_IRQ, NULL);
		tasklet_disable(&audioFromPsIntHandler);

		printk(KERN_NOTICE"[audio_from_ps] stopped by close\n");
    }
	running =0;
	module_put(THIS_MODULE); // kernel housekeeping!
    deviceOpenDesc = 0 ;


	kfree(dataW);
    up(&sync);
    return SUCCESS;
}

static int device_open(struct inode *inode, struct file *file) {
    int result;

    if (down_interruptible(&sync)){
	    return -ERESTARTSYS;
	}
    if (deviceOpenDesc) {
        up(&sync);
        return -EBUSY;
    }
    deviceOpenDesc = 1;
	audio_from_ps_flag=0;
	audio_from_ps_size				=	AUDIO_FROM_PS_MEM_SIZE;
	audio_from_ps_half_size			=	AUDIO_FROM_PS_BUF_SIZE_MAX;
	audio_from_ps_sample_per_buffer	=	AUDIO_FROM_PS_SAMPLE_PER_BUF_MAX;
	if(ioread32(&regBaseAddrPtr[0])&0x1)
	{
		iowrite32(AUDIO_FROM_PS_CLR_OFF, &regBaseAddrPtr[1]);
	}
	iowrite32(AUDIO_FROM_PS_OFF, &regBaseAddrPtr[1]);
	running =0;
	
	printk(KERN_INFO"[audio_from_ps] Open\n");
	

	dataW = 0;
	dataW = kmalloc(audio_from_ps_half_size,GFP_KERNEL);
	if(dataW == 0)
		printk(KERN_WARNING"[audio_from_ps] kmallok error\n");
	
    up(&sync);
	
    try_module_get(THIS_MODULE); // kernel housekeeping!

    return SUCCESS;
}

static struct file_operations fops = {
    .owner = THIS_MODULE,
	.read = device_read,
	.write = device_write,
	.open = device_open,
	.release = device_release,
	.unlocked_ioctl = device_ioctl,
};

static struct cdev dev_c;
static dev_t devNo = 0;
void bdCleanupModule(void) {
    release_mem_region(MEM_BASE_ADDRESS, 0xFFFF);
	release_mem_region(REG_BASE_ADDRESS, 0xFFFF);
    cdev_del(&dev_c);
    unregister_chrdev_region(devNo,1);
}
int bdInitModule(void) {
    int result;
    int major_n=0;

    result = alloc_chrdev_region(&devNo, 0, 1,DEVICE_NAME);
    if(result < 0){
        printk(KERN_WARNING "[audio_from_ps] %s: can't get device number: %d",DEVICE_NAME, result);
        return result;
    }
 	major_n=MAJOR(devNo);
	printk(KERN_INFO "[audio_from_ps] %s: 'mknod /dev/%s c %d 0'.\n",DEVICE_NAME,DEVICE_NAME, major_n);
	
	//Reserving register memory
	memBaseAddrPtr =(unsigned int *) request_mem_region(MEM_BASE_ADDRESS,0xFFFF, DEVICE_NAME);
    if (memBaseAddrPtr==NULL) {
        printk(KERN_INFO"%s: memBaseAddrPtr request_mem_region failure", DEVICE_NAME);
        return -ENOMEM;
    }
    memBaseAddrPtr = ioremap(MEM_BASE_ADDRESS, 0xFFFF);
    if (memBaseAddrPtr == NULL) {
        printk(KERN_INFO "%s: memBaseAddrPtr ioremap failure", DEVICE_NAME);
        return -ENOMEM;
    }

	regBaseAddrPtr =(unsigned int *) request_mem_region(REG_BASE_ADDRESS,0xFFFF, DEVICE_NAME);
    if (regBaseAddrPtr==NULL) {
        printk(KERN_INFO"%s: regBaseAddrPtr request_mem_region failure", DEVICE_NAME);
        return -ENOMEM;
    }
    regBaseAddrPtr = ioremap(REG_BASE_ADDRESS, 0xFFFF);
    if (regBaseAddrPtr == NULL) {
        printk(KERN_INFO "%s: memBaseAddrPtr ioremap failure", DEVICE_NAME);
        return -ENOMEM;
    }

	sema_init(&sync, 1); // initialized as mutex
    cdev_init(&dev_c, &fops);
    dev_c.owner = THIS_MODULE;
    result = cdev_add (&dev_c, devNo, 1);
    if (result) {
        printk(KERN_NOTICE"%s: Error %d adding module", DEVICE_NAME, result);
		bdCleanupModule();
        return result;
    }
    return SUCCESS;
}
	
module_init(bdInitModule);
module_exit(bdCleanupModule);
MODULE_AUTHOR("Andrea Albano [bdSound]");
MODULE_LICENSE("GPL");

