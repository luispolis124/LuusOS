# 🪐 LuusOS — Bare-Metal Operating System
[![Architecture](https://img.shields.io/badge/arch-AArch64%20%2F%20x86-blueviolet?style=for-the-badge)](https://github.com/luispolis124/LuusOS)
[![License](https://img.shields.io/badge/license-MIT-green?style=for-the-badge)](LICENSE)
[![Environment](https://img.shields.io/badge/environment-Bare--Metal-orange?style=for-the-badge)](https://github.com/luispolis124/LuusOS)
---
## 🇧🇷 Português
O **LuusOS** é um projeto independente e focado em engenharia de sistemas operacionais nativos (*OSDev*), projetado para explorar o controle direto de hardware, inicialização bare-metal e desenvolvimento de estruturas fundamentais de kernel a partir do zero absoluto.
O ecossistema é modularizado de modo flat e híbrido, suportando implementações robustas de baixo nível para **x86 (IA-32)** e portabilidade evolutiva para **AArch64 (ARM64)**.
### 🚀 Funcionalidades Atuais & Core Modules
* **Multiboot Integration:** Suporte a especificações padrão Multiboot e carregadores como GRUB, chaveando com segurança para o Modo Protegido de 32-bits (ou inicialização customizada em ARM Exception Level 1).
* **VGA Text Mode Driver:** Escrita direta no buffer mapeado em memória em `0xB8000` para saída de texto clássica $80 \times 25$ com manipulação manual de bytes de atributos (cores e fontes).
* **Low-Level Memory Management:** Implementação inicial da Global Descriptor Table (GDT), tabelas de paginação planas e isolamento preliminar de segmentos do Kernel (Ring 0).
* **Dual-Language Engine:** Lógica estruturada em **C** e **Rust** de alta performance apoiada por sub-rotinas cirúrgicas em **Assembly (NASM / GNU As)** para manipulação direta de registradores do processador.
### 🗺️ Mapa de Arquitetura do Sistema

| Componente | Endereço / Especificação Técnica | Descrição |
| :--- | :--- | :--- |
| **VGA Video Buffer** | `0xB8000` (Modo Texto) | Manipulação direta de caracteres emparelhados a cores. |
| **Bootloader Target** | x86 Flat / IA-32 / AArch64 Virt | Alvo de emulação escalável via QEMU. |
| **Kernel Stack Pointer** | Espaço reservado pré-alocado | Configurado manualmente na inicialização inicial do Assembly. |
| **Core Compilers** | GCC / Clang / LLVM / NASM | Cross-compilação e linkagem estrita sem dependências da `stdlib`. |

### 🛠️ Pré-requisitos & Instalação da Toolchain
Para compilar o LuusOS do código-fonte, garanta que seu ambiente possua as seguintes ferramentas instaladas:
```bash
# No Ubuntu/Debian/Termux
sudo apt update
sudo apt install build-essential nasm qemu-system-x86 qemu-system-arm xorriso grub-pc-bin cimg-dev clang lld
```
### 🏗️ Compilação & Build System
 1. **Clone o repositório:**
```bash
   git clone [https://github.com/luispolis124/LuusOS.git](https://github.com/luispolis124/LuusOS.git)
   cd LuusOS
```
 2. **Compile a imagem:**
```bash
   make clean && make all
```
### 🕹️ Execução & Emulação
#### 1. Via QEMU (Recomendado para Testes Rápidos)
 * **Executando em x86 (Modo Padrão):**
```bash
  # Testando a ISO estável gerada pelo build system
  qemu-system-i386 -cdrom build/luusos.iso
  # Testando via Kernel direto (Multiboot)
  qemu-system-i386 -kernel build/luusos.bin
```
 * **Executando em AArch64 (Modo ARM64 Virt):**
```bash
  qemu-system-aarch64 -M virt -cpu cortex-a57 -nographic -kernel target/LuusOS.bin
```
#### 2. Via VirtualBox (Ambiente de Virtualização Completo)
Para rodar a imagem do LuusOS no VirtualBox, siga os passos abaixo:
 1. Certifique-se de que o arquivo build/luusos.iso foi gerado com sucesso pelo make.
 2. Abra o VirtualBox e crie uma nova máquina virtual (Escolha o tipo *Other* / *Other/Unknown* 32-bit ou 64-bit dependendo do alvo atual de build).
 3. Vá em **Configurações > Armazenamento**, selecione a controladora IDE/Dispositivo Óptico e anexe o luusos.iso como um drive de CD virtual.
 4. Garanta que a ordem de boot esteja configurada para iniciar pelo drive óptico. (*Nota: Certifique-se de habilitar ou desabilitar o EFI nas configurações do sistema conforme o estado da build do seu bootloader*).
 5. Inicie a máquina virtual.
#### 3. Gravando em um Pendrive (Bare-Metal Real)
```bash
sudo dd if=build/luusos.iso of=/dev/sdX bs=4M && sync
```
## 🇺🇸 English
**LuusOS** is an independent hobbyist operating system kernel project (*OSDev*) designed for bare-metal system programming, hardware initialization, and developing fundamental kernel structures from scratch.
The ecosystem features a modular flat and hybrid structure, targeting robust low-level implementations for **x86 (IA-32)** alongside evolutionary portability for **AArch64 (ARM64)**.
### 🚀 Current Features & Core Modules
 * **Multiboot Integration:** Native support for standard Multiboot specifications and bootloaders like GRUB, safely switching into 32-bit Protected Mode (or custom initialization in ARM Exception Level 1).
 * **VGA Text Mode Driver:** Direct manipulation of the text video memory buffer mapped at 0xB8000 for classic 80 \times 25 output via custom attribute bytes (colors and fonts).
 * **Low-Level Memory Management:** Initial setup of the Global Descriptor Table (GDT), early paging tables, and basic isolation for high-privilege kernel segments (Ring 0).
 * **Dual-Language Engine:** High-performance architectural core built using **C** and **Rust**, coupled with fine-tuned **Assembly (NASM / GNU As)** routines for direct CPU register interaction.
### 🗺️ System Architecture Map

| Component | Target Address / Tech Specs | Description |
| :--- | :--- | :--- |
| **VGA Video Buffer** | 0xB8000 (Text Mode) | Direct buffer character and color manipulation. |
| **Bootloader Target** | x86 Flat / IA-32 / AArch64 Virt | Scalable emulation target via QEMU environments. |
| **Kernel Stack Pointer** | Pre-allocated reserved area | Set up manually during early Assembly initialization. |
| **Core Compilers** | GCC / Clang / LLVM / NASM | Freestanding cross-compilation with no stdlib links. |

### 🛠️ Prerequisites & Toolchain Setup
To build LuusOS from source, ensure you have the following packages installed:
```bash
# On Ubuntu/Debian/Termux environments
sudo apt update
sudo apt install build-essential nasm qemu-system-x86 qemu-system-arm xorriso grub-pc-bin cimg-dev clang lld
```
### 🏗️ Compilation & Build System
 1. **Clone the repository:**
```bash
   git clone [https://github.com/luispolis124/LuusOS.git](https://github.com/luispolis124/LuusOS.git)
   cd LuusOS
```
 2. **Build the image:**
```bash
   make clean && make all
```
### 🕹️ Running & Emulation
#### 1. Via QEMU (Recommended for Quick Testing)
 * **Running on x86 (Standard Mode):**
```bash
  # Testing the stable ISO image generated by the build system
  qemu-system-i386 -cdrom build/luusos.iso
  # Testing via raw Kernel binary (Multiboot)
  qemu-system-i386 -kernel build/luusos.bin
```
 * **Running on AArch64 (ARM64 Virt Mode):**
```bash
  qemu-system-aarch64 -M virt -cpu cortex-a57 -nographic -kernel target/LuusOS.bin
```
#### 2. Via VirtualBox (Full VM Virtualization)
To test LuusOS inside VirtualBox, follow these setup rules:
 1. Ensure build/luusos.iso was successfully compiled using make.
 2. Open VirtualBox and create a new Virtual Machine (Set OS Type to *Other* / *Other/Unknown* 32-bit or 64-bit depending on your compilation target).
 3. Open **Settings > Storage**, choose the IDE Controller / Optical Device, and attach your local luusos.iso file.
 4. Verify that the system's Boot Order gives priority to the optical drive. (*Note: Toggle EFI support on or off in the Motherboard configuration panel based on your bootloader structure*).
 5. Start the virtual machine.
#### 3. Flashing to a USB Drive (Bare-Metal Deployment)
```bash
sudo dd if=build/luusos.iso of=/dev/sdX bs=4M && sync
```
## 📦 🇧🇷 Download Rápido / 🇺🇸 Quick Download (Via Releases)
> 💡 **Nota / Note:**
>  * **PT:** Os binários pré-compilados (.bin) e as imagens ópticas (.iso) serão disponibilizados na aba de **Releases** em breve assim que as primeiras builds estáveis forem publicadas. Por enquanto, siga as instruções de compilação acima.
>  * **EN:** Pre-compiled standalone binaries (.bin) and bootable optical storage tags (.iso) will be published to the **Releases** section soon as stable milestones are established. For now, please build from source using the steps above.
> 
```bash
# PT: Comando futuro para baixar a imagem ISO estável
# EN: Future script to fetch the latest stable bootable ISO
curl -L -O [https://github.com/luispolis124/LuusOS/releases/latest/download/luusos.iso](https://github.com/luispolis124/LuusOS/releases/latest/download/luusos.iso)
# PT: Comando futuro para capturar apenas o binário estático do Kernel
# EN: Future script to download the bare-metal raw Kernel binary
wget [https://github.com/luispolis124/LuusOS/releases/latest/download/luusos.bin](https://github.com/luispolis124/LuusOS/releases/latest/download/luusos.bin)
```
## 📜 License & Contributing
Licensed under the **MIT License**. Feel free to study, modify, fork, and use this codebase for educational and OSDev experimentation purposes. Feedback, issue tracking, and architecture discussions are highly appreciated!
