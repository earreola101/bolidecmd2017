/*
 *  File		            : bus_module.c
 *	AUTHOR 					: Andrea Albano
 *	mail		            : andrea.albano@bdsound.com
 *	bdSound	             	: www.bdsound.com
 */

#include <linux/kernel.h> // printk()
#include <linux/module.h>
#include <linux/fs.h> // file system xface & registration
#include <asm/uaccess.h>	// for put_user 
#include <linux/init.h> // module definition
#include <linux/slab.h>		// kmalloc() 
#include <linux/sched.h>
#include <linux/errno.h> // error codes
#include <linux/delay.h>	// udelay 
#include <linux/kdev_t.h> // major & minor, actually not used
#include <linux/ioport.h> // request/release_mem_region
#include <linux/interrupt.h> // tasklets & interrupts
#include <linux/wait.h> // sleeping
#include <asm/io.h> // mapping of physical memory
#include <linux/cdev.h> // device driver registration
#include <linux/ioctl.h> // ioctl
#include "xparameters.h"
#include <linux/delay.h>
#include <linux/param.h>

#define KERNEL_BDSOUND
#define SUCCESS 0

#define DEVICE_NAME "bus"
MODULE_AUTHOR("Andrea Albano [bdSound]");
MODULE_LICENSE("GPL");

#define BUS_NUM			3


const u32 rx_bus_addr[BUS_NUM]={ 	XPAR_TDM_HUB_RX_DATA_BRAM_CTRL_0_S_AXI_BASEADDR,
									XPAR_TDM_HUB_RX_DATA_BRAM_CTRL_1_S_AXI_BASEADDR,
									XPAR_TDM_HUB_RX_DATA_BRAM_CTRL_2_S_AXI_BASEADDR};

const u32 tx_bus_addr=				XPAR_TDM_HUB_TX_DATA_BRAM_CTRL_S_AXI_BASEADDR;

const u32 comm_bus_addr[BUS_NUM]={ 	XPAR_TDM_HUB_COMM_MANAGER_0_BASEADDR,
									XPAR_TDM_HUB_COMM_MANAGER_1_BASEADDR,
									XPAR_TDM_HUB_COMM_MANAGER_2_BASEADDR};

const u32 bus_intr_id[BUS_NUM]={	XPAR_FABRIC_TDM_HUB_COMM_MANAGER_0_INTR0_INTR,
									XPAR_FABRIC_TDM_HUB_COMM_MANAGER_1_INTR0_INTR,
									XPAR_FABRIC_TDM_HUB_COMM_MANAGER_2_INTR0_INTR};
									

static int peripheral_number=0;



//General command manager definition
//RX READ REG
#define RX_REG_READ			0
#define RX_LEN_SHIFT		0
#define RX_LEN_MASK			0xFFFF
#define RX_VALID_SHIFT		16
#define RX_LOCKED_SHIFT		17
//RX WRITE REG
#define RX_REG_WRITE		1
#define RX_GOT_SHIFT		0
#define RX_PROBE_SHIFT		1
#define RX_ENABLE_SHIFT		2

//TX WRITE REG
#define TX_REG_WRITE		2
#define TX_LEN_SHIFT		0
#define TX_LEN_MASK			0xFFFF


#define TX_VALID_SHIFT		16
#define TX_PROBE_SHIFT		17
#define TX_DIR_SHIFT		18
#define TX_ENABLE_SHIFT		19

//TX READ REG
#define TX_REG_READ			3
#define TX_GOT_SHIFT		0


//TX register command manager definition



#define MAX_PACKET_LEN		1024

// device data
static int deviceOpenDesc[BUS_NUM]; 
volatile unsigned char *tx;
volatile unsigned char *rx[BUS_NUM];
volatile unsigned int *comm[BUS_NUM];
volatile unsigned int dev_id_num[BUS_NUM];
static struct semaphore sync[BUS_NUM];

static DECLARE_WAIT_QUEUE_HEAD(queue);

void tasklet(unsigned long unused);
irqreturn_t intrHandler(int irq, void *dev_id);
DECLARE_TASKLET_DISABLED(deviceTasklet, tasklet, 0);


volatile unsigned int message_present[BUS_NUM];
volatile unsigned char message_buf[BUS_NUM][MAX_PACKET_LEN];
volatile int message_len[BUS_NUM];
volatile int bus_dir[BUS_NUM];

#define BUS_IOC_MAGIC 'y'
#define BUS_IOC_MAXNR 1


#define BUS_SET_BUF_DIR _IOW(BUS_IOC_MAGIC,1,unsigned int)
void tasklet(unsigned long unused) {
	int i,j;
	//printk(KERN_INFO "Tasklet\n");
	for(i=0; i<BUS_NUM; i++)
	{
		if(!message_present[i])
		{
			unsigned int valid = (ioread32(&comm[i][RX_REG_READ])>>RX_VALID_SHIFT)&0x01;
			if(valid)
			{
				//printk(KERN_INFO "Found message %d\n",i);
				int lenGot = (ioread32(&comm[i][RX_REG_READ])>>RX_LEN_SHIFT)&RX_LEN_MASK;
				for(j=0;j<lenGot; j++)
				{
					message_buf[i][j] = ioread32(&rx[i][j]);
			
				}
				message_len[i]=lenGot;
				//removing clear interrupt

				message_present[i]=1;
			}
		}
	}

    wake_up_interruptible(&queue);
}

irqreturn_t intrHandler(int irq, void *dev_id) 
{
	unsigned int devNum = ((unsigned int *)dev_id)[0];
	//clear interrupt
	//printk(KERN_INFO "Intr %d\n",devNum);
	tasklet_schedule(&deviceTasklet);  
    return IRQ_HANDLED;
}


static long device_ioctl(struct file *filp, unsigned int cmd,unsigned long arg) {
	int result = SUCCESS;
	int minor = iminor(filp->f_path.dentry->d_inode);
	unsigned int auxR;
    if (_IOC_TYPE(cmd) != BUS_IOC_MAGIC) return -ENOTTY;
	if (_IOC_NR(cmd) > BUS_IOC_MAXNR) return -ENOTTY;
    switch (cmd) {
        case BUS_SET_BUF_DIR :
	    {
			printk(KERN_INFO "[Bus module] Set buffer dir %d\n",arg);
			bus_dir[minor] = arg&0x1;
			auxR = ((bus_dir[minor]&0x1)<<TX_DIR_SHIFT)|(1<<TX_ENABLE_SHIFT);
			iowrite32(auxR,&comm[minor][TX_REG_WRITE]);

			return SUCCESS;
	    }
	    default:
	        return -ENOTTY;
    }
}

static ssize_t device_read(struct file *filp, char __user *buffer,size_t len, loff_t *off) {
	int result = SUCCESS;
	int i;
	unsigned char auxC;
	unsigned char * uBuffer= (unsigned int * )buffer;
	int minor = iminor(filp->f_path.dentry->d_inode);
	//printk(KERN_INFO "Read minor %d\n",minor);
	int res = wait_event_interruptible_timeout(queue, message_present[minor] != 0,1);
	if(res==0)
		return 0;
	//printk(KERN_INFO "[Bus module] Read \n",minor);
	int lenGot = message_len[minor];
	for(i=0;i<lenGot; i++)
	{
		put_user(message_buf[minor][i],(&uBuffer[i]));
	}
	iowrite32((1<<RX_GOT_SHIFT)|(1<<RX_ENABLE_SHIFT),&comm[minor][RX_REG_WRITE]);
	wmb();
	message_present[minor]=0;
	tasklet_schedule(&deviceTasklet); 
	return lenGot;
}



//byte da 0 a 3 indirizzo registro
//byte da 4 a 7 dato da scrivere
//Len dev'essere sempre 8
static ssize_t device_write(struct file *filp,const char __user *buffer,size_t len, loff_t *off) {
	int i;
	unsigned int auxR;
	unsigned char auxC;
	unsigned char * uBuffer= (unsigned int * )buffer;
	int minor = iminor(filp->f_path.dentry->d_inode);
	unsigned int timeout=0;
	unsigned int busy=(ioread32(&comm[minor][TX_REG_WRITE])>>TX_VALID_SHIFT)&0x01;
	while(busy)
	{
		timeout++;
		if(timeout>= 100)
		{
			printk(KERN_INFO "[Bus module] timeout\n");
			return 0;
		}
		udelay(10);
		busy=(ioread32(&comm[minor][TX_REG_WRITE])>>TX_VALID_SHIFT)&0x01;
	}		
	//printk(KERN_INFO "[Bus module] write\n");
	for(i=0; i<len; i++)
	{
		get_user(auxC,&uBuffer[i]);
		iowrite8(auxC,&tx[i]);
	}
	wmb();
	auxR = ((len&TX_LEN_MASK)<<TX_LEN_SHIFT)|(1<<TX_VALID_SHIFT)|(bus_dir[minor]<<TX_DIR_SHIFT)|(1<<TX_ENABLE_SHIFT);
	iowrite32(auxR,&comm[minor][TX_REG_WRITE]);
	//printk(KERN_INFO "[Bus module] write complete\n");
	return len;
}

static int device_release(struct inode *inode, struct file *file) {

	unsigned int minor = MINOR(inode->i_rdev);
    if (down_interruptible(&sync[minor])){ 
	    return -ERESTARTSYS;
    }
	printk(KERN_INFO "[Bus module] Device release minor %d\n",minor);
	iowrite32(0,&comm[minor][TX_REG_WRITE]);
	iowrite32(0,&comm[minor][RX_REG_WRITE]);
	wmb();
	module_put(THIS_MODULE); // kernel housekeeping!
	deviceOpenDesc[minor] = 0 ;
    up(&sync[minor]);
    return SUCCESS;
}

static int device_open(struct inode *inode, struct file *file) {
    int result;
	int i;
	unsigned int minor = MINOR(inode->i_rdev);
    if (down_interruptible(&sync[minor])){
	    return -ERESTARTSYS;
	}
    if (deviceOpenDesc[minor] ) {
        up(&sync[minor]);
        return -EBUSY;
    }
	
    deviceOpenDesc[minor] = 1;
	iowrite32(1<<RX_GOT_SHIFT,&comm[minor][RX_REG_WRITE]);
	iowrite32(0,&comm[minor][TX_REG_WRITE]);
	wmb();
	printk(KERN_INFO "[Bus module] Device open minor %d\n",minor);
	iowrite32(1<<RX_ENABLE_SHIFT,&comm[minor][RX_REG_WRITE]);
	iowrite32(1<<TX_ENABLE_SHIFT,&comm[minor][TX_REG_WRITE]);	
	up(&sync[minor]);
	
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
	int i;

	release_mem_region(tx_bus_addr, 0xFFFF);
	for(i=0; i<BUS_NUM; i++)
	{
		iowrite32(0,&comm[i][TX_REG_WRITE]);
		iowrite32(0,&comm[i][RX_REG_WRITE]);
		release_mem_region(rx_bus_addr[i], 0xFFFF);
		release_mem_region(comm_bus_addr[i], 0xFFFF);
		free_irq(bus_intr_id[i],  &dev_id_num[i]);
    }
	tasklet_disable(&deviceTasklet);
	cdev_del(&dev_c);
    unregister_chrdev_region(devNo,BUS_NUM);
}
int bdInitModule(void) {

    int result;
    int major_n=0;
	int i;

    result = alloc_chrdev_region(&devNo, 0, BUS_NUM,DEVICE_NAME);
    if(result < 0){
        printk(KERN_WARNING "%s: can't get device number: %d",DEVICE_NAME, result);
        return result;
    }
 	major_n=MAJOR(devNo);
	for(i=0; i<BUS_NUM; i++)
		printk(KERN_INFO "%s: 'mknod /dev/%s%d c %d %d'.\n",DEVICE_NAME,DEVICE_NAME, i, major_n, i);

	tx = NULL;
	tx =(unsigned int *) request_mem_region(tx_bus_addr,0xFFFF, DEVICE_NAME);
	if (tx==NULL) {
		printk(KERN_INFO"%s: tx %d request_mem_region failure %x \n", DEVICE_NAME, i,tx_bus_addr);
		return -ENOMEM;
	}
	tx = ioremap(tx_bus_addr, 0xFFFF);
	if (tx == NULL) {
		printk(KERN_INFO "%s: tx %d ioremap failure", DEVICE_NAME,i);
		return -ENOMEM;
	}
	//Reserving register memory
	for(i=0; i<BUS_NUM; i++)
	{
		deviceOpenDesc[i]=0;
		message_present[i]=0;
		dev_id_num[i]=i;

		rx[i] = NULL;
		rx[i] =(unsigned int *) request_mem_region(rx_bus_addr[i],0xFFFF, DEVICE_NAME);
		if (rx[i]==NULL) {
			printk(KERN_INFO"%s: rx %d request_mem_region failur%x \ne", DEVICE_NAME,i,rx_bus_addr[i]);
			return -ENOMEM;
		}
		rx[i] = ioremap(rx_bus_addr[i], 0xFFFF);
		if (rx[i] == NULL) {
			printk(KERN_INFO "%s: rx %d ioremap failure", DEVICE_NAME,i);
			return -ENOMEM;
		}
		comm[i] = NULL;
		comm[i] =(unsigned int *) request_mem_region(comm_bus_addr[i],0xFFFF, DEVICE_NAME);
		if (comm[i]==NULL) {
			printk(KERN_INFO"%s: comm %d request_mem_region failure%x \n", DEVICE_NAME,i,comm_bus_addr[i]);
			return -ENOMEM;
		}
		comm[i] = ioremap(comm_bus_addr[i], 0xFFFF);
		if (comm[i] == NULL) {
			printk(KERN_INFO "%s: comm %d ioremap failure", DEVICE_NAME,i);
			return -ENOMEM;
		}
		iowrite32(0,&comm[i][TX_REG_WRITE]);
		iowrite32(0,&comm[i][RX_REG_WRITE]);
		
		/*
		int count = 0;
		int short_irq =0;
		do {
			unsigned long mask;

			mask = probe_irq_on();
			iowrite32(1,&comm[i][RX_REG_GOT]);
			udelay(5);
			iowrite32(2,&comm[i][RX_REG_GOT]);
			udelay(5);
			iowrite32(1,&comm[i][RX_REG_GOT]);
			udelay(5); 
			short_irq = probe_irq_off(mask);

			if (short_irq == 0) { 
				printk(KERN_INFO "short: no irq reported by probe\n");
				short_irq = -1;
			}

		} while (short_irq < 0 && count++ < 5);
		if (short_irq < 0)
			printk("short: probe failed %i times, giving up\n", count);
		result = request_irq(short_irq, intrHandler, 0, DEVICE_NAME, NULL);
		*/
		result = request_irq(bus_intr_id[i], intrHandler, IRQF_TRIGGER_RISING, DEVICE_NAME, &dev_id_num[i]);

				
		if (result) {
			printk(KERN_INFO "%s: can't get irq assigned for minor %d, error %d\n",DEVICE_NAME, i, result);
			deviceOpenDesc[i] = 0;
			return -EIO;
		}
		sema_init(&sync[i], 1); // initialized as mutex
	}
	tasklet_enable(&deviceTasklet);
    cdev_init(&dev_c, &fops);
    dev_c.owner = THIS_MODULE;
    result = cdev_add (&dev_c, devNo, BUS_NUM);
    if (result) {
        printk(KERN_NOTICE"%s: Error %d adding module", DEVICE_NAME, result);
		bdCleanupModule();
        return result;
    }
    return SUCCESS;
}
	
module_init(bdInitModule);
module_exit(bdCleanupModule);

