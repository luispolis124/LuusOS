@echo off
setlocal

:: ============================================================
::  LuusOS Build Script
::  Usage:
::    build.bat          -> compile + link -> luusos.bin only
::    build.bat iso      -> compile + link + create bootable ISO
::    build.bat img      -> compile + link + create raw disk image
::    build.bat all      -> compile + link + both ISO and IMG
:: ============================================================

set CC=bin\i686-elf-gcc.exe
set AS=bin\i686-elf-as.exe
set LD=bin\i686-elf-ld.exe

:: Check for cross-compiler
if not exist bin\i686-elf-gcc.exe (
    echo [ERROR] Cross-compiler not found: bin\i686-elf-gcc.exe
    echo         Please ensure the i686-elf toolchain is in the bin\ folder.
    pause
    exit /b 1
)

set TARGET=%~1
if "%TARGET%"=="" set TARGET=bin

echo.
echo ============================================================
echo  LuusOS Build System
echo ============================================================
echo.

:: ============================================================
::  STEP 1 — Compile all C and assembly sources
:: ============================================================

echo [1/2] Compiling sources...

echo   Assembling src\boot.s
%AS% src\boot.s -o boot.o
if errorlevel 1 goto :error

echo   Assembling src\gdt_flush.s
%AS% src\gdt_flush.s -o gdt_flush.o
if errorlevel 1 goto :error

echo   Assembling src\isr.s
%AS% src\isr.s -o isr.o
if errorlevel 1 goto :error

echo   Compiling src\gdt.c
%CC% -c src\gdt.c -o gdt.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra
if errorlevel 1 goto :error

echo   Compiling src\idt.c
%CC% -c src\idt.c -o idt.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra
if errorlevel 1 goto :error

echo   Compiling src\kernel.c
%CC% -c src\kernel.c -o kernel.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra
if errorlevel 1 goto :error

echo   Compiling src\keyboard.c
%CC% -c src\keyboard.c -o keyboard.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra
if errorlevel 1 goto :error

echo   Compiling src\string.c
%CC% -c src\string.c -o string.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra
if errorlevel 1 goto :error

echo   Compiling src\shell.c
%CC% -c src\shell.c -o shell.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra
if errorlevel 1 goto :error

echo   Compiling src\sound.c
%CC% -c src\sound.c -o sound.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra
if errorlevel 1 goto :error

echo   Compiling src\timer.c
%CC% -c src\timer.c -o timer.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra
if errorlevel 1 goto :error

:: ============================================================
::  STEP 2 — Link into luusos.bin
:: ============================================================

echo.
echo [2/2] Linking luusos.bin...
%CC% -T linker.ld -o luusos.bin -ffreestanding -O2 -nostdlib ^
    boot.o gdt_flush.o isr.o gdt.o idt.o kernel.o keyboard.o ^
    string.o shell.o sound.o timer.o -lgcc
if errorlevel 1 goto :error

echo.
echo [OK] luusos.bin built successfully.

:: ============================================================
::  OPTIONAL — Generate ISO image
:: ============================================================

if /i "%TARGET%"=="iso" goto :make_iso
if /i "%TARGET%"=="all" goto :make_iso
goto :check_img

:make_iso
echo.
echo [ISO] Building bootable ISO image...

:: Verify grub-mkrescue is available
where grub-mkrescue >nul 2>&1
if errorlevel 1 (
    echo.
    echo [WARNING] grub-mkrescue not found in PATH.
    echo           Install GRUB tools via one of:
    echo             - MSYS2:  pacman -S grub
    echo             - WSL:    sudo apt install grub-pc-bin xorriso mtools
    echo           Then add the bin to your Windows PATH.
    echo.
    goto :check_img
)

:: Build ISO directory structure
if exist isodir rmdir /s /q isodir
mkdir isodir\boot\grub

copy /y luusos.bin isodir\boot\luusos.bin >nul
copy /y grub.cfg   isodir\boot\grub\grub.cfg >nul

:: Create the ISO
grub-mkrescue -o luusos.iso isodir
if errorlevel 1 (
    echo [ERROR] grub-mkrescue failed.
    goto :check_img
)

echo [OK] luusos.iso created!
echo      Run with: qemu-system-i386 -cdrom luusos.iso

:check_img
if /i "%TARGET%"=="img" goto :make_img
if /i "%TARGET%"=="all" goto :make_img
goto :done

:: ============================================================
::  OPTIONAL — Generate raw disk image (flat binary with MBR stub)
:: ============================================================

:make_img
echo.
echo [IMG] Building raw disk image (luusos.img)...

:: Check for dd (available in Git for Windows / MSYS2 / WSL)
where dd >nul 2>&1
if errorlevel 1 (
    echo.
    echo [WARNING] 'dd' not found in PATH.
    echo           Install Git for Windows (which includes dd) or MSYS2.
    echo           Skipping IMG generation.
    echo.
    goto :done
)

:: Create a 32 MB blank image
dd if=/dev/zero of=luusos.img bs=512 count=65536 2>nul
if errorlevel 1 goto :img_error

:: Check for grub-install (writes GRUB MBR to the image)
where grub-install >nul 2>&1
if errorlevel 1 (
    echo.
    echo [WARNING] grub-install not found — IMG will be a raw zero-padded binary.
    echo           For a proper bootable image, install GRUB tools (see ISO notes above).
    echo.
    :: Fallback: just copy the bin at the start (works with qemu -kernel)
    copy /b luusos.bin + luusos.img luusos.img >nul 2>&1
    echo [OK] luusos.img created (raw binary, use with: qemu-system-i386 -kernel luusos.bin)
    goto :done
)

:: Use grub-install to write a bootable GRUB MBR
grub-install --target=i386-pc --boot-directory=isodir\boot --no-floppy luusos.img
if errorlevel 1 goto :img_error

:: Copy kernel to image (requires loop mount — typically needs WSL/Linux)
echo.
echo [NOTE] To fully write the kernel to the img, mount it in WSL/Linux:
echo        sudo mount -o loop,offset=1048576 luusos.img /mnt
echo        sudo cp luusos.bin /mnt/boot/
echo        sudo umount /mnt
echo.
echo [OK] luusos.img MBR written.
echo      Run with: qemu-system-i386 -drive format=raw,file=luusos.img
goto :done

:img_error
echo [ERROR] Failed to create disk image.
goto :done

:: ============================================================
::  Summary
:: ============================================================

:done
echo.
echo ============================================================
echo  Build complete!
echo ============================================================
echo.
echo  Files produced:
echo    luusos.bin  -- Multiboot kernel (always built)
if exist luusos.iso echo    luusos.iso  -- Bootable ISO (GRUB)
if exist luusos.img echo    luusos.img  -- Raw disk image
echo.
echo  QEMU commands:
echo    Kernel only : qemu-system-i386 -kernel luusos.bin
if exist luusos.iso echo    ISO (CDROM) : qemu-system-i386 -cdrom luusos.iso
if exist luusos.img echo    Disk image  : qemu-system-i386 -drive format=raw,file=luusos.img
echo.
pause
exit /b 0

:error
echo.
echo [ERROR] Build failed! Check the output above for details.
echo.
pause
exit /b 1
