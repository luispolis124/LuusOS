# LuusOS

LuusOS is a hobbyist operating system kernel designed for the **AArch64 (ARM64)** architecture. This project focuses on bare-metal system programming, hardware initialization, and the development of essential kernel drivers from scratch.

## Features
- **Architecture:** AArch64 (ARMv8).
- **Toolchain:** Built using `clang` and `lld`.
- **Drivers:** Initialized UART and VGA support.
- **Goal:** Educational project exploring OS internals, memory management, and low-level development.

## Prerequisites
To build LuusOS, you need the following tools installed:
- `clang`
- `lld`
- `make`
- `xorriso` (for ISO creation)

## How to Build
1. Clone the repository:
   ```bash
   git clone [https://github.com/luispolis124/LuusOS.git](https://github.com/luispolis124/LuusOS.git)
   cd LuusOS

```
 2. Compile the project:
   ```bash
   make
   
   ```
This will generate target/LuusOS.bin and other artifacts in the target/ directory.
## Running the OS
You can test the kernel using QEMU:
```bash
qemu-system-aarch64 -M virt -cpu cortex-a57 -nographic -kernel target/LuusOS.bin

```
## License
This project is licensed under the **MIT License**. Feel free to use, modify, and learn from this code.
## Contributing
As this is an educational project, feedback and learning discussions are welcome!
```
