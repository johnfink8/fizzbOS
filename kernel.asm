; This file only exists to hand off execution to the C code
bits 32		

global start
extern kernel_main	

start:

	cli	
	call kernel_main ; this should never return
	hlt	