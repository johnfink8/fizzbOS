fizzbOS.fdd : loader.bin kernel
	dd if=/dev/zero bs=1024 count=1440 of=fizzbOS.fdd
	dd if=loader.bin of=fizzbOS.fdd bs=512 count=1 conv=notrunc
	dd if=kernel of=fizzbOS.fdd bs=512 seek=1 conv=notrunc

loader.bin : loader.asm
	nasm -f bin loader.asm -o loader.bin

kernelasm.o : kernel.asm
	nasm -f elf32 kernel.asm -o kernelasm.o

kernel.o : kernel.c kernel.h 
	gcc -nodefaultlibs -nostdlib -m32 -c kernel.c -o kernel.o

string.o : string.c string.h
	gcc -nodefaultlibs -nostdlib -m32 -c string.c -o string.o

kernel : kernelasm.o kernel.o string.o link.ld
	ld -m elf_i386 -T link.ld -o kernel kernelasm.o kernel.o string.o

clean : 
	rm -f *.o kernel *.bin *.fdd
