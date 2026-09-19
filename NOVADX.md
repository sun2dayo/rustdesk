# NovaDX Assistência Remota

Fork do [RustDesk](https://github.com/rustdesk/rustdesk) (AGPL-3.0) com a marca NovaDX,
ligado ao servidor próprio `remoto.novadx.pt` e à consola `https://remoto.novadx.pt/_admin/`.

## Variantes

| Variante | Executável | App / serviço | Uso |
|---|---|---|---|
| `suporte` | `NovaDX-Assistencia-<versão>.exe` | `NovaDX` | Portátil, só entrada. O cliente dita o ID e a senha temporária. |
| `agente` | `NovaDX-Agente-<versão>.exe` | `NovaDXAgente` | Instalado como serviço, só entrada, acesso não assistido com senha permanente única por posto. Instalar com `res/novadx/deploy-agente.ps1`. |
| `tecnico` | `NovaDX-Tecnico-<versão>.exe` | `NovaDXTecnico` | Equipa NovaDX, só saída, login e livro de endereços na consola. |

Todas trazem servidor, chave e API server fixos e não procuram atualizações da RustDesk oficial.
Os nomes de app não podem ter espaços (são usados sem aspas em `sc create` / `taskkill`).

## Alterações face ao RustDesk

| Ficheiro | Alteração |
|---|---|
| `src/common.rs` | `novadx_builtin_config()`: configuração embutida por variante (`NOVADX_VARIANT`) |
| `libs/portable/src/main.rs` | Pasta de extração por variante (`NOVADX_PORTABLE_DIR`) |
| `res/novadx/` | Logo de origem, `apply_branding.py` (ícones) e `deploy-agente.ps1` |
| `Cargo.toml`, `libs/portable/Cargo.toml`, `flutter/windows/runner/Runner.rc` | Metadados do executável |
| `.github/workflows/novadx-windows.yml` | Build Windows x64 das três variantes |

## Compilar

- **Manual:** Actions → *NovaDX Windows* → *Run workflow* (variante ou `todas`).
- **Release:** `git tag novadx-1.4.9-1 && git push origin novadx-1.4.9-1` (compila as três).

Assinatura opcional com os secrets `WINDOWS_PFX_BASE64` e `WINDOWS_PFX_PASSWORD`.

## Instalar o agente num posto

```powershell
powershell -ExecutionPolicy Bypass -File deploy-agente.ps1 -Cliente "Nome do cliente"
```

O script instala o serviço, gera uma senha permanente **única** para o posto, obtém o ID
e copia ID + senha para a área de transferência, para guardar no cofre. A senha não fica
escrita no posto. O posto aparece sozinho na consola (Devices).

## Atualizar para uma nova versão do RustDesk

```bash
git fetch upstream --tags
git rebase <nova-tag>        # a partir do branch novadx
```

Rever `VERSION` e `VCPKG_COMMIT_ID` em `novadx-windows.yml` face ao `flutter-build.yml` da nova tag.

## Licença

AGPL-3.0, como o projeto original. O código-fonte desta versão está neste repositório.
