@echo off
setlocal enabledelayedexpansion

:: ============================================================
::  SELEÇÃO DE IDIOMA / LANGUAGE SELECTION
:: ============================================================
echo Select the build language / Selecione o idioma do build:
echo  [1] Portugues (BR)
echo  [2] English (US)
echo.
choice /c 12 /n /m "Choose/Escolha (1 or 2): "

if errorlevel 2 (
    set LANG=EN
) else if errorlevel 1 (
    set LANG=PT
)

cls
echo ============================================================
echo   LuusOS Build System — Windows PC (w64devkit)
echo ============================================================
echo.

:: Configura os executáveis locais instalados na pasta bin via w64devkit
set CC="%~dp0bin\gcc.exe" -m32
set AS="%~dp0bin\as.exe" --32
set LD="%~dp0bin\ld.exe" -m elf_i386

if not exist "%~dp0bin\gcc.exe" (
    if "!LANG!"=="PT" (
        echo [ERRO] Compilador nao encontrado na pasta bin!
        echo Rode o comando do PowerShell para baixar a toolchain primeiro.
    ) else (
        echo [ERROR] Compiler not found in bin folder!
        echo Run the PowerShell command to download the toolchain first.
    )
    echo.
    pause
    exit /b 1
)

:: Menu Interativo de Seleção de Alvo
if "!LANG!"=="PT" (
    echo Escolha o tipo de compilacao desejado:
    echo  [1] Apenas Kernel (luusos.bin)
    echo  [2] Kernel + Imagem Optica (luusos.iso)
    echo.
    choice /c 12 /n /m "Digite a opcao desejada (1 ou 2): "
) else (
    echo Choose the desired build target:
    echo  [1] Kernel Only (luusos.bin)
    echo  [2] Kernel + Optical Image (luusos.iso)
    echo.
    choice /c 12 /n /m "Enter your choice (1 or 2): "
)

if errorlevel 2 (
    set TARGET=iso
) else if errorlevel 1 (
    set TARGET=bin
)

echo.
echo ============================================================
if "!LANG!"=="PT" (echo [INFO] Alvo selecionado: !TARGET!) else (echo [INFO] Selected target: !TARGET!)
echo ============================================================
echo.

:: ============================================================
::  PASSO 1 — Compilação dos Módulos
:: ============================================================
if "!LANG!"=="PT" (echo [1/2] Compilando arquivos de codigo-fonte...) else (echo [1/2] Compiling source files...)

if "!LANG!"=="PT" (echo   Montando src/boot.s) else (echo   Assembling src/boot.s)
%AS% -c src/boot.s -o boot.o
if errorlevel 1 goto :error

if "!LANG!"=="PT" (echo   Montando src/gdt_flush.s) else (echo   Assembling src/gdt_flush.s)
%AS% -c src/gdt_flush.s -o gdt_flush.o
if errorlevel 1 goto :error

if "!LANG!"=="PT" (echo   Montando src/isr.s) else (echo   Assembling src/isr.s)
%AS% -c src/isr.s -o isr.o
if errorlevel 1 goto :error

if "!LANG!"=="PT" (echo   Compilando src/gdt.c) else (echo   Compiling src/gdt.c)
%CC% -c src/gdt.c -o gdt.o -ffreestanding -O2 -Wall -Wextra -std=gnu99
if errorlevel 1 goto :error

if "!LANG!"=="PT" (echo   Compilando src/idt.c) else (echo   Compiling src/idt.c)
%CC% -c src/idt.c -o idt.o -ffreestanding -O2 -Wall -Wextra -std=gnu99
if errorlevel 1 goto :error

if "!LANG!"=="PT" (echo   Compilando src/kernel.c) else (echo   Compiling src/kernel.c)
%CC% -c src/kernel.c -o kernel.o -ffreestanding -O2 -Wall -Wextra -std=gnu99
if errorlevel 1 goto :error

if "!LANG!"=="PT" (echo   Compilando src/keyboard.c) else (echo   Compiling src/keyboard.c)
%CC% -c src/keyboard.c -o keyboard.o -ffreestanding -O2 -Wall -Wextra -std=gnu99
if errorlevel 1 goto :error

if "!LANG!"=="PT" (echo   Compilando src/string.c) else (echo   Compiling src/string.c)
%CC% -c src/string.c -o string.o -ffreestanding -O2 -Wall -Wextra -std=gnu99
if errorlevel 1 goto :error

if "!LANG!"=="PT" (echo   Compilando src/shell.c) else (echo   Compiling src/shell.c)
%CC% -c src/shell.c -o shell.o -ffreestanding -O2 -Wall -Wextra -std=gnu99
if errorlevel 1 goto :error

if "!LANG!"=="PT" (echo   Compilando src/sound.c) else (echo   Compiling src/sound.c)
%CC% -c src/sound.c -o sound.o -ffreestanding -O2 -Wall -Wextra -std=gnu99
if errorlevel 1 goto :error

if "!LANG!"=="PT" (echo   Compilando src/timer.c) else (echo   Compiling src/timer.c)
%CC% -c src/timer.c -o timer.o -ffreestanding -O2 -Wall -Wextra -std=gnu99
if errorlevel 1 goto :error

:: ============================================================
::  PASSO 2 — Linkagem do Executável do Kernel
:: ============================================================
echo.
if "!LANG!"=="PT" (echo [2/2] Linkando objetos no binario estavel luusos.bin...) else (echo [2/2] Linking objects into stable luusos.bin...)
%LD% -T linker.ld -o luusos.bin boot.o gdt_flush.o isr.o gdt.o idt.o kernel.o keyboard.o string.o shell.o sound.o timer.o
if errorlevel 1 goto :error

if "!LANG!"=="PT" (echo [OK] Kernel luusos.bin gerado com sucesso!) else (echo [OK] Kernel luusos.bin successfully generated!)

:: ============================================================
::  GERAÇÃO DA ISO (SE SELECIONADA)
:: ============================================================
if /i "%TARGET%"=="iso" goto :make_iso
goto :done

:make_iso
echo.
if "!LANG!"=="PT" (echo [ISO] Verificando ferramentas de geracao de imagem...) else (echo [ISO] Checking image generation tools...)

where grub-mkrescue >nul 2>&1
if errorlevel 1 (
    if "!LANG!"=="PT" (
        echo [INFO] 'grub-mkrescue' nao encontrado no PATH do Windows.
        echo        Pulando geracao do arquivo luusos.iso.
        echo        (O binario luusos.bin foi criado e pode ser usado direto no QEMU).
    ) else (
        echo [INFO] 'grub-mkrescue' not found in Windows PATH.
        echo        Skipping luusos.iso generation.
        echo        (The luusos.bin binary was built and can be used directly in QEMU).
    )
    goto :done
)

if exist isodir rmdir /s /q isodir
mkdir isodir\boot\grub

copy /y luusos.bin isodir\boot\luusos.bin >nul
copy /y grub.cfg   isodir\boot\grub\grub.cfg >nul

grub-mkrescue -o luusos.iso isodir
if errorlevel 1 (
    if "!LANG!"=="PT" (echo [AVISO] Falha ao executar o grub-mkrescue.) else (echo [WARNING] Failed to execute grub-mkrescue.)
    goto :done
)

if "!LANG!"=="PT" (echo [OK] Imagem bootavel luusos.iso gerada com sucesso!) else (echo [OK] Bootable image luusos.iso successfully generated!)
if exist isodir rmdir /s /q isodir

:done
:: Limpeza dos arquivos temporários de objeto
del *.o >nul 2>&1
echo.
echo ============================================================
if "!LANG!"=="PT" (echo   Build finalizado!) else (echo   Build complete!)
echo ============================================================
echo.
pause
exit /b 0

:error
echo.
if "!LANG!"=="PT" (echo [ERRO] Ocorreu uma falha durante o processo de compilacao.) else (echo [ERROR] A failure occurred during the compilation process.)
echo.
pause
exit /b 1
