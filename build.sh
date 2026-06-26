#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Define variables
# If you have a specific cross-compiler prefix, set it here (e.g., i686-elf-)
# If you are on a standard Linux distro and have the native compiler (though not recommended for bare metal),
# you might use no prefix or set CC=gcc. For OSDev, i686-elf-gcc is highly recommended.
CC="gcc -m32"
AS="as --32"

echo "Checking for cross-compiler..."
if ! command -v gcc &> /dev/null; then
    echo "Warning: $CC could not be found."
    echo "If you don't have a cross-compiler, this build may fail or produce invalid binaries."
    echo "You can try changing CC='gcc' and AS='as' in this script if you are on Linux,"
    echo "but it is not recommended for a bare-metal OS."
    # If on windows, maybe they use x86_64-w64-mingw32-gcc. But let's stick to standard names.
fi

echo "Assembling boot.s..."
$AS src/boot.s -o boot.o

echo "Compiling kernel.c..."
$CC -c src/kernel.c -o kernel.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra

echo "Linking into luusos.bin..."
$CC -T linker.ld -o luusos.bin -ffreestanding -O2 -nostdlib boot.o kernel.o -lgcc

# Check if the generated file is multiboot compliant
echo "Checking multiboot header..."
if command -v grub-file &> /dev/null; then
    if grub-file --is-x86-multiboot luusos.bin; then
        echo "multiboot confirmed"
    else
        echo "the file is not multiboot"
        exit 1
    fi
else
    echo "grub-file not found, skipping multiboot check."
fi

# Optional: Generate ISO
echo "Generating ISO (optional)..."
if command -v grub-mkrescue &> /dev/null; then
    mkdir -p isodir/boot/grub
    cp luusos.bin isodir/boot/luusos.bin
    cp grub.cfg isodir/boot/grub/grub.cfg
    grub-mkrescue -o luusos.iso isodir
    echo "luusos.iso created successfully!"
else
    echo "grub-mkrescue not found. Skipping ISO creation."
    echo "You need GRUB tools installed to create the bootable ISO."
fi

echo "Build complete."
echo "To run with QEMU, you can use:"
echo "  qemu-system-i386 -kernel luusos.bin"
echo "Or if you generated the ISO:"
echo "  qemu-system-i386 -cdrom luusos.iso"
