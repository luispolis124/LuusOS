# ❓ Frequently Asked Questions / Perguntas Frequentes

---

## 🇧🇷 Português

### 1. O que é o LuusOS?
O LuusOS é um projeto de sistema operacional independente e focado em engenharia nativa (*Bare-Metal*). Ele não é uma distribuição Linux e não usa o kernel de nenhum outro sistema; ele está sendo construído do zero absoluto para fins de estudo, portfólio e exploração de baixo nível.

### 2. Em quais linguagens o LuusOS é escrito?
O núcleo (kernel) é estruturado de forma híbrida utilizando **C** e **Rust** pela alta performance e controle de memória. Sub-rotinas cirúrgicas e o processo de boot inicial usam **Assembly (NASM / GNU As)** para conversar direto com os registradores do processador.

### 3. Posso rodar programas do Linux ou Windows no LuusOS?
Não de forma nativa. Como o LuusOS possui um kernel próprio e ainda está em estágio inicial de desenvolvimento de drivers e chamadas de sistema (*syscalls*), ele não possui as bibliotecas necessárias para executar softwares de terceiros.

### 4. Como posso testar o sistema?
A forma mais rápida e recomendada é via emulação com o **QEMU** ou **VirtualBox** no computador (compatível com Linux e Windows via WSL2/MSYS2). Se você estiver no celular (Android), você também pode rodar a ISO usando o **Limbo PC Emulator** ou compilar pelo ambiente **Termux**.

### 5. Posso rodar o LuusOS em uma máquina real (Bare-Metal)?
Sim, você pode gravar a imagem `luusos.iso` em um pendrive usando o comando `dd` (ou ferramentas como Rufus) e dar boot direto por ele. Porém, por estar em desenvolvimento inicial, o suporte a mouses, teclados USB específicos e telas pode variar dependendo do hardware real. O uso de emuladores é mais seguro para testes.

### 6. É possível baixar o LuusOS pronto sem precisar compilar?
Sim! Se você não quiser configurar toda a toolchain de compilação local, você pode ir direto na aba **Releases** do repositório no GitHub. Lá serão disponibilizados os binários do Kernel compilados (`luusos.bin`) e as imagens prontas para emulador (`luusos.iso`) assim que as primeiras builds estáveis forem publicadas.

---

## 🇺🇸 English

### 1. What is LuusOS?
LuusOS is an independent, hobbyist bare-metal operating system built entirely from scratch. It is not a Linux distribution, nor does it inherit any third-party kernel structures. It is tailored for educational systems programming and OSDev experimentation.

### 2. Which programming languages are used?
The core ecosystem combines **C** and **Rust** for robust, high-performance kernel logic and typesafe low-level mutations. Fine-tuned initialization blocks and boot hooks leverage **Assembly (NASM / GNU As)** to interface directly with CPU registers.

### 3. Can I run Windows or Linux software on LuusOS?
No. Because LuusOS implements an entirely custom kernel and is currently establishing basic core drivers and syscall interfaces, standard runtime environments or binaries from other OS platforms are not supported.

### 4. How can I test and run LuusOS?
The most reliable approach is running the output within **QEMU** or **VirtualBox** virtual machines. If you are developing on mobile hardware, you can easily deploy and execute the system using the **Limbo PC Emulator** app on Android or handle builds inside the **Termux** environment.

### 5. Can I boot LuusOS on actual real hardware?
Yes, you can flash the compiled `luusos.iso` image onto a physical USB drive (using `dd` or flashing utilities) and perform a native hardware boot. However, due to its early lifecycle phase, component/driver compliance (like custom USB controllers) is limited. Emulators remain the safest environment for testing.

### 6. Can I download pre-built binaries without compiling from source?
Yes! If you prefer to bypass the local toolchain setup, you can navigate directly to the **Releases** tab on the GitHub repository page. Pre-compiled Kernel binaries (`luusos.bin`) and bootable CD-ROM optical storage tags (`luusos.iso`) will be hosted there as stable target milestones are published.

