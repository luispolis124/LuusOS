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
if errorlevel 2 (set LANG=EN) else (set LANG=PT)

cls
echo ============================================================
echo   LuusOS Build System — Windows PC
echo ============================================================
echo.

:: Caminhos dos executáveis
set "BIN_DIR=%~dp0bin"
set "CC=%BIN_DIR%\i686-elf-gcc.exe"
set "AS=%BIN_DIR%\i686-elf-as.exe"
set "LD=%BIN_DIR%\i686-elf-ld.exe"

:: ============================================================
::  VERIFICAÇÃO E DOWNLOAD AUTOMÁTICO
:: ============================================================
if not exist "%BIN_DIR%" mkdir "%BIN_DIR%"

if not exist "%CC%" (
    if "!LANG!"=="PT" (echo [INFO] Compilador nao encontrado. Iniciando download...) else (echo [INFO] Compiler not found. Starting download...)
    
    if not exist toolchain_tmp mkdir toolchain_tmp
    powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://github.com/lordmilko/i686-elf-tools/releases/download/7.1.0/i686-elf-tools-windows.zip' -OutFile 'toolchain_tmp\toolchain.zip'"
    
    if exist toolchain_tmp\toolchain.zip (
        powershell -Command "Expand-Archive -Path 'toolchain_tmp\toolchain.zip' -DestinationPath 'bin\' -Force"
        rmdir /s /q toolchain_tmp
    ) else (
        echo [ERRO] Falha no download.
        pause & exit /b 1
    )
)

:setup_menu
if "!LANG!"=="PT" (
    echo Escolha o tipo de compilacao:
    echo  [1] Apenas Kernel (luusos.bin)
    echo  [2] Kernel + Imagem ISO
    echo.
    choice /c 12 /n /m "Opcao (1 ou 2): "
) else (
    echo Choose build target:
    echo  [1] Kernel Only (luusos.bin)
    echo  [2] Kernel + ISO Image
    echo.
    choice /c 12 /n /m "Choice (1 or 2): "
)

set TARGET=bin
if errorlevel 2 set TARGET=iso

echo.
echo ============================================================
echo [INFO] Alvo selecionado: !TARGET!
echo ============================================================
echo.

:: ============================================================
::  COMPILAÇÃO
:: ============================================================
call :compile src/boot.s boot.o -c
call :compile src/gdt_flush.s gdt_flush.o -c
call :compile src/isr.s isr.o -c
call :compile src/gdt.c gdt.o "-c -ffreestanding -O2 -Wall -Wextra -std=gnu99"
call :compile src/idt.c idt.o "-c -ffreestanding -O2 -Wall -Wextra -std=gnu99"
call :compile src/kernel.c kernel.o "-c -ffreestanding -O2 -Wall -Wextra -std=gnu99"
call :compile src/keyboard.c keyboard.o "-c -ffreestanding -O2 -Wall -Wextra -std=gnu99"
call :compile src/string.c string.o "-c -ffreestanding -O2 -Wall -Wextra -std=gnu99"
call :compile src/shell.c shell.o "-c -ffreestanding -O2 -Wall -Wextra -std=gnu99"
call :compile src/sound.c sound.o "-c -ffreestanding -O2 -Wall -Wextra -std=gnu99"
call :compile src/timer.c timer.o "-c -ffreestanding -O2 -Wall -Wextra -std=gnu99"

:: ============================================================
::  LINKAGEM
:: ============================================================
"%LD%" -m elf_i386 -T linker.ld -o luusos.bin boot.o gdt_flush.o isr.o gdt.o idt.o kernel.o keyboard.o string.o shell.o sound.o timer.o
if errorlevel 1 goto :error

if /i "%TARGET%"=="iso" goto :make_iso
goto :done

:: ============================================================
::  FUNÇÃO COMPILE CORRIGIDA
:: ============================================================
:compile
if "%~2"=="boot.o" (set "CMD=%AS% --32") else if "%~2"=="gdt_flush.o" (set "CMD=%AS% --32") else if "%~2"=="isr.o" (set "CMD=%AS% --32") else (set "CMD=%CC% -m32")
echo    Compilando %~1...
%CMD% %~3 %~1 -o %~2
if errorlevel 1 goto :error
exit /b

:make_iso
where grub-mkrescue >nul 2>&1
if errorlevel 1 (echo [AVISO] grub-mkrescue nao encontrado. & goto :done)
if exist isodir rmdir /s /q isodir
mkdir isodir\boot\grub
copy /y luusos.bin isodir\boot\luusos.bin >nul
copy /y grub.cfg isodir\boot\grub\grub.cfg >nul
grub-mkrescue -o luusos.iso isodir >nul 2>&1
echo [OK] luusos.iso gerada.
if exist isodir rmdir /s /q isodir
goto :done

:done
del *.o >nul 2>&1
echo Build concluído com sucesso!
pause & exit /b 0

:error
echo [ERRO] Falha no processo.
pause & exit /b 1
