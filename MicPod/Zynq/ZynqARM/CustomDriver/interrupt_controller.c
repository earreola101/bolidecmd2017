#include "interrupt_controller.h"
#include "xscugic.h"
#include "stdio.h"
XScuGic InterruptController; 	     /* Instance of the Interrupt Controller */
static XScuGic_Config *GicConfig;    /* The configuration parameters of the
                                       controller */

int interrupt_init()
{
	int Status;

	/*
	 * Initialize the interrupt controller driver so that it is ready to
	 * use.
	 */
	GicConfig = XScuGic_LookupConfig(XPAR_SCUGIC_0_DEVICE_ID);
	if (NULL == GicConfig) {
		printf("XScuGic_LookupConfig error\n");
		return XST_FAILURE;
	}

	Status = XScuGic_CfgInitialize(&InterruptController, GicConfig,
					GicConfig->CpuBaseAddress);
	if (Status != XST_SUCCESS) {
		printf("XScuGic_CfgInitialize error\n");
		return XST_FAILURE;
	}


	/*
	 * Perform a self-test to ensure that the hardware was built
	 * correctly
	 */
	Status = XScuGic_SelfTest(&InterruptController);
	if (Status != XST_SUCCESS) {
		printf("Self test error\n");
		return XST_FAILURE;
	}

	/*
	 * Connect the interrupt controller interrupt handler to the hardware
	 * interrupt handling logic in the ARM processor.
	 */
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
			(Xil_ExceptionHandler) XScuGic_InterruptHandler,
			&InterruptController);

	/*
	 * Enable interrupts in the ARM
	 */
	Xil_ExceptionEnable();
	return XST_SUCCESS;
}


int interrupt_connect(u32 intr_id, void * callback, void * user_data, u8 priority, u8 trigger)
{
	int Status = XScuGic_Connect(&InterruptController, intr_id,
			   (Xil_ExceptionHandler)callback,
			   user_data);
	if (Status != XST_SUCCESS) {
		printf("Interrupt connect error\n");
		return XST_FAILURE;
	}
//	XScuGic_SetPriorityTriggerType(&InterruptController, intr_id, priority, trigger);
//	printf("Successfully connected interrupt %d\n",intr_id);
	return XST_SUCCESS;
}

void interrupt_enable(u32 intr_id)
{
	XScuGic_Enable(&InterruptController, intr_id);
}

void interrupt_disable(u32 intr_id)
{
	XScuGic_Disable(&InterruptController, intr_id);
}

