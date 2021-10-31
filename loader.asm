bits	16

org		0x7c00 ; BIOS loads me in at this address

start:          jmp loader

Print:
			lodsb
			or			al, al
			jz			PrintDone
			mov			ah,	0eh
			int			10h
			jmp			Print
PrintDone:
			ret


; actual entry point of the code
loader:
    mov si, msgBegin
    call Print
    cli
    mov ax,cs ; cs is set to the segment we're in, populate that to the other registers
    mov ds,ax
    mov es,ax
    mov ss,ax  
    mov bp,7c00h
    mov sp,7c00h            ; Setup a stack
    sti

jmp	main
 
 
%include "gdt.inc"
 
sector: DB 2
 
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

    ; we're reading into segment es==0x0E00, and offset bx==0
    ; That's a memory address 0xE000 for the start of the kernel binary
    ; The kernel code starts at 0x100 bytes into the binary, before that
    ; is ELF headers.  So when we call that kernel code, we'll call
    ; it at 0xE000 + 0x0100 = 0xE100
    ; I don't have a good reason to choose that particualr segment 0x0E00
    ; It worked and I stuck with it.  This could probably be optimized
    ; if you absolutely positively have to print fizzbuzz on something
    ; with only a couple KB of memory.

    xor ax,ax
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

bits 16

msgBegin  db 0x0D, 0x0A, "Starting ", 0x0D, 0x0A, 0x00
msgStacked db 0x0D, 0x0A, "Stack Loaded ", 0x0D, 0x0A, 0x00
msgLoading  db 0x0D, 0x0A, "Loading Boot Image ", 0x0D, 0x0A, 0x00
msgLoaded  db 0x0D, 0x0A, "Loaded Boot Image ", 0x0D, 0x0A, 0x00
msgLoadFail  db 0x0D, 0x0A, "Boot Image Fail ", 0x0D, 0x0A, 0x00
msgProgress db ".", 0x00
msgFailure  db 0x0D, 0x0A, "ERROR : Press Any Key to Reboot", 0x0A, 0x00


times 510 - ($-$$) db 0	; fill zeros until the end of the block

dw 0xAA55 ; mark this as a bootable sector
