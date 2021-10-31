# fizzbOS
Simple legacy bootloader and OS that just prints FizzBuzz to the screen.

## Why?

This is really just a silly project to unwind from a lot of more "serious" work.
It's basically a proof of concept to load a "full" OS kernel from the ground up, without using any outside projects like grub or other bootloaders or libraries.  The whole thing not only fits in one floppy disk, but doesn't use much space on that disk at all, coming in at around 3 kilobytes.

## Setup
    apt-get install -y gcc nasm build-essential

## Build
    make

## Running
You can either write the contents of fizzbOS.fdd to a physical floppy and boot it, or you can run it in qemu, bochs, or any other VM probably.  It seems to work in anything I've tried.

## Structure
- loader.asm - This is the bootloader, it will be loaded into the first block of the floppy image.  The BIOS will take this 512 byte block (and only this block), load it into memory, and start execution at the first byte.  loader.asm is responsible for loading the kernel from disk, switching to 32-bit "protected" mode, and handing off control to the kernel.  Typically this would be done in two stages, because of that 512 byte limit.  It would normally read from a filesystem to get a second stage bootloader, and that second stage would have all the room it needs without that 512 byte limit.  But we have no filesystem, and no OEM identifiers taking up room in our boot sector, so we have enough room to go straight to loading the kernel from this initial bootloader.  loader.asm is assembled with nasm, and then used directly without any additional linking.
- kernel.asm - This is the entry point for the kernel, this is what loader.asm executes.  This one gets linked in with kernel.o as one package.  The linker puts this at a fixed position based on the link.ld script, so we can go straight to that spot in memory and hand off control to it.
- kernel.c - The main logic, and the most straightforward.  The only complicated thing is that we don't have any syscalls or standard library stuff, no dynamic memory allocation, none of that.  So we keep everything in static assignments and we have to write directly to the video memory for printing.