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

:: Configura os executáveis usando a estrutura do w64devkit
:: O bin deve estar na pasta 'bin' ao lado deste script
set "BIN_DIR=%~dp0bin"
set "CC=%BIN_DIR%\gcc.exe"
set "AS=%BIN_DIR%\as.exe"
set "LD=%BIN_DIR%\ld.exe"

:: Verificação de segurança
if not exist "%CC%" (
    if "!LANG!"=="PT" (
        echo [ERRO] O w64devkit nao foi encontrado!
        echo O arquivo gcc.exe nao foi localizado em: %BIN_DIR%
        echo Certifique-se de que o build.bat esta na mesma pasta que a pasta 'bin'.
    ) else (
        echo [ERROR] w64devkit not found!
        echo The file gcc.exe was not located in: %BIN_DIR%
        echo Make sure build.bat is in the same directory as the 'bin' folder.
    )
    echo.
    pause
    exit /b 1
)

:setup_menu
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
::  PASSO 2 — Linkagem do Executável do Kernel
:: ============================================================
echo.
if "!LANG!"=="PT" (echo [2/2] Linkando objetos no binario estavel luusos.bin...) else (echo [2/2] Linking objects into stable luusos.bin...)
"%LD%" -m elf_i386 -T linker.ld -o luusos.bin boot.o gdt_flush.o isr.o gdt.o idt.o kernel.o keyboard.o string.o shell.o sound.o timer.o
if errorlevel 1 goto :error

if "!LANG!"=="PT" (echo [OK] Kernel luusos.bin gerado com sucesso!) else (echo [OK] Kernel luusos.bin successfully generated!)

:: ============================================================
::  GERAÇÃO DA ISO (SE SELECIONADA)
:: ============================================================
if /i "%TARGET%"=="iso" goto :make_iso
goto :done

:: ============================================================
::  FUNÇÕES AUXILIARES
:: ============================================================
:compile
if "%~2"=="boot.o" (set "CMD="%AS%" --32") else if "%~2"=="gdt_flush.o" (set "CMD="%AS%" --32") else if "%~2"=="isr.o" (set "CMD="%AS%" --32") else (set "CMD="%CC%" -m32")
if "!LANG!"=="PT" (echo    Compilando %~1...) else (echo    Compiling %~1...)
%CMD% %~3 %~1 -o %~2
if errorlevel 1 goto :error
exit /b

:make_iso
echo.
if "!LANG!"=="PT" (echo [ISO] Verificando ferramentas de geracao de imagem...) else (echo [ISO] Checking image generation tools...)
where grub-mkrescue >nul 2>&1
if errorlevel 1 (
    if "!LANG!"=="PT" (
        echo [INFO] 'grub-mkrescue' nao encontrado no PATH. Pulando geracao da ISO.
    ) else (
        echo [INFO] 'grub-mkrescue' not found. Skipping ISO generation.
    )
    goto :done
)
if exist isodir rmdir /s /q isodir
mkdir isodir\boot\grub
copy /y luusos.bin isodir\boot\luusos.bin >nul
copy /y grub.cfg   isodir\boot\grub\grub.cfg >nul
grub-mkrescue -o luusos.iso isodir >nul 2>&1
if "!LANG!"=="PT" (echo [OK] Imagem bootavel luusos.iso gerada com sucesso!) else (echo [OK] Bootable image luusos.iso successfully generated!)
if exist isodir rmdir /s /q isodir
goto :done

:done
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
