# 🛡️ Security Policy / Política de Segurança
---
## 🇧🇷 Português
### Política de Suporte a Versões
Atualmente, o **LuusOS** é um projeto de sistema operacional focado em aprendizado, experimentação e desenvolvimento bare-metal (*OSDev*). Por estar em estágio inicial e de desenvolvimento ativo, apenas a versão mais recente na branch principal recebe atualizações e correções.

| Versão | Suportada | Notas |
| :--- | :--- | :--- |
| **Branch `main` / Última Build** | 🟢 Sim | Versão atual em desenvolvimento ativo. |
| **Versões Anteriores** | 🔴 Não | Atualize para a build mais recente para obter correções. |

### Como Reportar uma Vulnerabilidade
Se você encontrar alguma falha de segurança grave, estouros de buffer inesperados fora do isolamento do Kernel (Ring 0) ou qualquer comportamento que comprometa a integridade da emulação, por favor siga os passos abaixo:
1. **Não abra uma Issue pública** imediatamente para falhas de segurança críticas.
2. Reporte o problema diretamente abrindo um alerta privado de vulnerabilidade na aba **Security > Vulnerability reporting** do repositório no GitHub (caso esteja ativo).
3. Alternativamente, você pode entrar em contato via e-mail ou mensagens diretas associadas ao perfil do mantenedor principal.
Agradecemos por ajudar a manter o ambiente de desenvolvimento do LuusOS seguro!
---
## 🇺🇸 English
### Supported Versions
**LuusOS** is currently an independent hobbyist operating system project focused on low-level system engineering and bare-metal experimentation. Because the ecosystem is under active development, only the latest commit/build on the primary branch is maintained.

| Version | Supported | Notes |
| :--- | :--- | :--- |
| **`main` Branch / Latest Build** | 🟢 Yes | Current active development and milestone tracking. |
| **Past Releases** | 🔴 No | Please upgrade to the latest master/main branch build. |

### Reporting a Vulnerability
If you discover a critical security vulnerability, severe memory/buffer overflows, or an issue that breaks kernel execution isolation structures ungracefully, please follow these steps:
1. **Do not open a public Issue** describing critical bugs or exploits immediately.
2. Report the vulnerability privately via GitHub's built-in **Security > Vulnerability reporting** tab on the repository interface.
3. If preferred, contact the lead developer directly using the private channels specified on the main GitHub profile.
Thank you for supporting stable and secure bare-metal operating system development!
