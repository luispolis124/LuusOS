#!/bin/bash

# Aborta o script imediatamente se qualquer comando falhar
set -e

echo "============================================================"
echo "  LuusOS Build System — Linux / Termux (Android)"
echo "============================================================"
echo ""

# 1. DETECÇÃO DE AMBIENTE (TERMUX vs PC NATIVO)
if [ -d "$HOME/.termux" ] || [ -n "$TERMUX_VERSION" ]; then
    echo "[INFO] Ambiente Termux detectado no Android."
    # No Termux, o Clang é o melhor cross-compiler nativo para x86 bare-metal
    CC="clang -target i686-pc-none-elf"
    AS="clang -target i686-pc-none-elf"
    LD="ld.lld"
    # Flags adicionais para o Clang emular freestanding puro
    CFLAGS="-ffreestanding -O2 -Wall -Wextra -std=gnu99 -march=i686"
    LDFLAGS="-T linker.ld -nostdlib -static"
else
    echo "[INFO] Ambiente Linux (PC) detectado."
    
    # Verifica se a toolchain i686-elf-tools local existe
    if [ ! -f "bin/i686-elf-gcc" ]; then
        echo "[INFO] i686-elf-gcc local não encontrado. Baixando toolchain estável..."
        mkdir -p toolchain_tmp
        
        # Puxa a release estável do i686-elf-tools para Linux
        curl -L -o toolchain_tmp/toolchain.tar.gz "https://github.com/lordmilko/i686-elf-tools/releases/download/7.1.0/i686-elf-tools-linux.tar.gz" || \
        wget -O toolchain_tmp/toolchain.tar.gz "https://github.com/lordmilko/i686-elf-tools/releases/download/7.1.0/i686-elf-tools-linux.tar.gz"
        
        mkdir -p bin
        tar -xzf toolchain_tmp/toolchain.tar.gz -C bin/ --strip-components=1
        rm -rf toolchain_tmp
        echo "[OK] Toolchain Linux configurada com sucesso!"
    fi

    CC="bin/i686-elf-gcc"
    AS="bin/i686-elf-as"
    CFLAGS="-c -std=gnu99 -ffreestanding -O2 -Wall -Wextra"
    LDFLAGS="-T linker.ld -ffreestanding -O2 -nostdlib"
fi

# ============================================================
#  PASSO 1 — Montagem e Compilação dos Módulos
# ============================================================
echo ""
echo "[1/2] Compilando arquivos de código-fonte..."

# Montagem do boot e rotinas Assembly
echo "   Montando src/boot.s"
$AS -c src/boot.s -o boot.o

echo "   Montando src/gdt_flush.s"
$AS -c src/gdt_flush.s -o gdt_flush.o

echo "   Montando src/isr.s"
$AS -c src/isr.s -o isr.o

# Compilação dos módulos em C do Kernel
echo "   Compilando src/gdt.c"
$CC $CFLAGS src/gdt.c -o gdt.o

echo "   Compilando src/idt.c"
$CC $CFLAGS src/idt.c -o idt.o

echo "   Compilando src/kernel.c"
$CC $CFLAGS src/kernel.c -o kernel.o

echo "   Compilando src/keyboard.c"
$CC $CFLAGS src/keyboard.c -o keyboard.o

echo "   Compilando src/string.c"
$CC $CFLAGS src/string.c -o string.o

echo "   Compilando src/shell.c"
$CC $CFLAGS src/shell.c -o shell.o

echo "   Compilando src/sound.c"
$CC $CFLAGS src/sound.c -o sound.o

echo "   Compilando src/timer.c"
$CC $CFLAGS src/timer.c -o timer.o

# ============================================================
#  PASSO 2 — Linkagem do Executável do Kernel
# ============================================================
echo ""
echo "[2/2] Linkando objetos no binário estável luusos.bin..."

if [ -d "$HOME/.termux" ] || [ -n "$TERMUX_VERSION" ]; then
    # Linkagem específica via LLD no Android Termux
    $LD $LDFLAGS boot.o gdt_flush.o isr.o gdt.o idt.o kernel.o keyboard.o string.o shell.o sound.o timer.o -o luusos.bin
else
    # Linkagem padrão via GCC Cross-Compiler no PC
    $CC $LDFLAGS -o luusos.bin boot.o gdt_flush.o isr.o gdt.o idt.o kernel.o keyboard.o string.o shell.o sound.o timer.o -lgcc
fi

echo "[OK] Kernel luusos.bin gerado com sucesso!"

# ============================================================
#  VERIFICAÇÃO MULTIBOOT
# ============================================================
echo ""
echo "Verificando consistência do Header Multiboot..."
if command -v grub-file &> /dev/null; then
    if grub-file --is-x86-multiboot luusos.bin; then
        echo "   -> [Sucesso]: Estrutura Multiboot confirmada!"
    else
        echo "   -> [Erro]: O binário quebrado não atende à especificação Multiboot."
        exit 1
    fi
else
    echo "   -> 'grub-file' não instalado. Pulando checagem de assinatura."
fi

# ============================================================
#  PASSO OPCIONAL — Geração de Imagem ISO de Boot
# ============================================================
echo ""
echo "Gerando imagem ISO óptica (Opcional)..."
if command -v grub-mkrescue &> /dev/null; then
    mkdir -p isodir/boot/grub
    cp luusos.bin isodir/boot/luusos.bin
    cp grub.cfg isodir/boot/grub/grub.cfg
    grub-mkrescue -o luusos.iso isodir
    rm -rf isodir
    echo "[OK] Imagem estável luusos.iso criada com sucesso!"
else
    echo "   -> 'grub-mkrescue' não encontrado no PATH atual. Pulando geração de ISO."
    echo "   -> (Para gerar ISOs no Termux, use xorriso, grub-pc-bin ou rode direto via .bin no Limbo/QEMU)."
fi

# Limpeza de arquivos de objeto temporários (.o) do diretório raiz
rm -f *.o

echo ""
echo "============================================================"
echo "  Build finalizado!"
echo "============================================================"
echo "Comandos QEMU recomendados para teste:"
echo "  Apenas Kernel : qemu-system-i386 -kernel luusos.bin"
if [ -f "luusos.iso" ]; then
    echo "  Imagem ISO    : qemu-system-i386 -cdrom luusos.iso"
fi
echo ""
