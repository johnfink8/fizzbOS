
bits	16

InstallGDT:

	cli
	pusha
	lgdt 	[gdt_location]
	sti
	popa
	ret


gdt_data: 
	dd 0
	dd 0
	dw 0FFFFh 
	dw 0
	db 0
	db 10011010b
	db 11001111b
	db 0
	dw 0FFFFh
	dw 0
	db 0
	db 10010010b
	db 11001111b
	db 0

end_of_gdt:
gdt_location: 
	dw end_of_gdt - gdt_data - 1 
	dd gdt_data
