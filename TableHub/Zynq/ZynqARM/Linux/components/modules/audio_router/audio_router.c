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

#define DEVICE_NAME "audio_router"

// imported from xparameters.h



#define REG_BASE_ADDRESS		XPAR_TDM_HUB_AUDIO_ROUTER_BASEADDR



// device data
static int deviceOpenDesc = 0; // to prevent multiple access
volatile unsigned int *regBaseAddrPtr = NULL; // pointer to
static struct semaphore sync;



static ssize_t device_read(struct file *filp, char __user *buffer,size_t len, loff_t *off) {
	return 0;
}




static ssize_t device_write(struct file *filp,const char __user *buffer,size_t len, loff_t *off) {
	unsigned int addr;
	int i;
	int pos;
	uint32_t audio_routing_reg[4];
	uint8_t routing_table[15];
	copy_from_user(routing_table,buffer,15);
	for(i=0; i<15; i++)
	{
		audio_routing_reg[i/4]&=~(0xFF<<(8*(i%4)));
		audio_routing_reg[i/4]|=routing_table[i]<<(8*(i%4));
	}
	for(i=0; i<4; i++)	
	{
		iowrite32(audio_routing_reg[i], &regBaseAddrPtr[i]);
	}
	return 15;
}
	

static int device_release(struct inode *inode, struct file *file) {
	int result;
    if (down_interruptible(&sync)){ 
	    return -ERESTARTSYS;
    }

	module_put(THIS_MODULE); // kernel housekeeping!
    deviceOpenDesc = 0 ;

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
};

static struct cdev dev_c;
static dev_t devNo = 0;
void bdCleanupModule(void) {
	release_mem_region(REG_BASE_ADDRESS, 0xFFFF);
    cdev_del(&dev_c);
    unregister_chrdev_region(devNo,1);
}
int bdInitModule(void) {
    int result;
    int major_n=0;

    result = alloc_chrdev_region(&devNo, 0, 1,DEVICE_NAME);
    if(result < 0){
        printk(KERN_WARNING "%s: can't get device number: %d",DEVICE_NAME, result);
        return result;
    }
 	major_n=MAJOR(devNo);
	printk(KERN_INFO "%s: 'mknod /dev/%s c %d 0'.\n",DEVICE_NAME,DEVICE_NAME, major_n);
	
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

