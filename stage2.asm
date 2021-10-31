bits	16
 
org 0x500
 
jmp	main
 
 
%include "gdt.inc"
 
sector: DB 9
 
main:
 
	cli 		; set up the stack
	xor	ax, ax
	mov	ds, ax
	mov	es, ax
	mov	ax, 0x9000
	mov	ss, ax
	mov	sp, 0xFFFF
	sti
 
	; read the kernel code from the disk

	mov cx, 12 ; hardcoded number of sectors to read
    xor bx,bx
loop1
	push cx
	mov ax, 0xe00
    mov es, ax
    xor ax,ax ; clear ax because al and ah are used below separately

    mov ah, 0x0
    mov dl, 0x0 ; drive number
    int 0x13 ; reset the drive
    mov ah, 0x2 ; read command
    mov al, 1 ; # of sectors (512b)
    mov ch, 0x0 ; cylinder #
    mov cl, [sector] 
    mov dh, 0x0 ; head #
    int 0x13  ; read one sector into bx
	add bx, 512
	mov ax, [sector]
	inc ax
	mov [sector], ax
	pop cx
	loop loop1

 
 
	call	InstallGDT
 
 
	cli				
	push	ax
	mov	al, 0xdd ; enable a20 gate
	out	0x64, al
	pop	ax

	mov	eax, cr0		
	or	eax, 1
	mov	cr0, eax	; start protected mode
 
	jmp	08h:KernelLoader
 
 
bits 32
 
KernelLoader:
  
	mov		ax, 0x10		; set data segments to data selector (0x10)
	mov		ds, ax
	mov		ss, ax
	mov		es, ax
	mov		esp, 90000h		; stack begins from 90000h

	mov eax, 0xe100
	mov ebp, eax
	call ebp

