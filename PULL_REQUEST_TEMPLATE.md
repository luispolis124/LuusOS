# 🚀 Pull Request Template / Gerenciamento de PR

---

## 🇧🇷 Português

### 📝 Descrição do Que Foi Feito
*Forneça um resumo claro das alterações introduzidas neste Pull Request (ex: Correção no driver VGA, configuração de nova tabela GDT, sub-rotinas em Assembly, etc.).*

### 🛠️ Tipo de Alteração
Marque com um `[x]` a opção que se aplica:
- [ ] 🐛 Correção de Bug (Bug Fix)
- [ ] ✨ Nova Funcionalidade / Módulo do Kernel (Feature)
- [ ] 🧼 Refatoração ou Limpeza de Código (Refactor)
- [ ] 📚 Atualização de Documentação (Docs)
- [ ] 🧪 Adição/Modificação de Testes ou Scripts de Build (`Makefile`)

### 🗺️ Subsistema Afetado
Em qual camada do LuusOS essa alteração se aplica?
- [ ] Inicialização / Bootloader (Multiboot / Assembly)
- [ ] Drivers de Vídeo / Texto (VGA `0xB8000`)
- [ ] Gerenciamento de Memória (GDT / Paging)
- [ ] Lógica do Kernel em C / Rust
- [ ] Ambiente de Emulação / Toolchain (QEMU / Limbo / Docker)

### 🧪 Como isso foi testado?
*Descreva brevemente como você validou a build. Exemplo:*
* `make clean && make all` compilou sem avisos.
* Testado no emulador **QEMU** (x86 / AArch64).
* Testado no dispositivo móvel via **Limbo PC Emulator**.

---

## 🇺🇸 English

### 📝 Description of Changes
*Provide a clear summary of the changes introduced in this Pull Request (e.g., VGA driver fixes, new GDT table structural alignment, Assembly hooks, etc.).*

### 🛠️ Type of Change
Check the options that apply with an `[x]`:
- [ ] 🐛 Bug Fix
- [ ] ✨ New Feature / Core Kernel Module
- [ ] 🧼 Code Refactoring / Cleanup
- [ ] 📚 Documentation Update
- [ ] 🧪 Build System / Toolchain Scripting (`Makefile`)

### 🗺️ Affected Architecture Layer
Where within the LuusOS codebase do these updates take place?
- [ ] Early Boot / Bootstrap Execution (Multiboot / Entry Assembly)
- [ ] Video & Display Output (VGA Text Buffer `0xB8000`)
- [ ] Memory Management & Segmentation (GDT / Early Paging)
- [ ] Hybrid Kernel Logic (C Components / Rust Modules)
- [ ] Emulation Environment / Toolchain Deployment (QEMU / Limbo Architecture)

### 🧪 How Has This Been Tested?
*Briefly describe the test cases executed to verify your build. Example:*
* Verified that `make clean && make all` builds freestanding with no errors.
* Evaluated standard behavior within target **QEMU** environments.
* Handled target deployment testing inside **Limbo PC Emulator** frameworks.

