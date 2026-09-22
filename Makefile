all:
	mkdir -p build
	nasm -f bin boot.asm -o build/boot.bin

run: all
	qemu-system-i386 -fda build/boot.bin
