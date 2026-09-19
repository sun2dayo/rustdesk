# NovaDX Assistência Remota

Fork do [RustDesk](https://github.com/rustdesk/rustdesk) (AGPL-3.0) com a marca NovaDX,
ligado ao servidor próprio `remoto.novadx.pt`.

## Alterações face ao RustDesk

| Ficheiro | Alteração |
|---|---|
| `src/common.rs` | Configuração embutida (`novadx_builtin_config`): nome, servidor, chave, modo de ligação, definições escondidas |
| `res/novadx/` | Logo de origem e `apply_branding.py`, que gera os ícones na compilação |
| `Cargo.toml`, `libs/portable/Cargo.toml`, `flutter/windows/runner/Runner.rc` | Metadados do executável |
| `libs/portable/src/main.rs` | Pasta de extração `%LOCALAPPDATA%\novadx-assistencia` (não colide com um RustDesk oficial) |
| `.github/workflows/novadx-windows.yml` | Build Windows x64 |

## Compilar

- **Manual:** Actions → *NovaDX Windows* → *Run workflow* (`incoming` = cliente de suporte, `outgoing` = técnico).
- **Release:** `git tag novadx-1.4.9-1 && git push origin novadx-1.4.9-1`.

Assinatura opcional com os secrets `WINDOWS_PFX_BASE64` e `WINDOWS_PFX_PASSWORD`.

## Atualizar para uma nova versão do RustDesk

```bash
git fetch upstream --tags
git rebase <nova-tag>        # a partir do branch novadx
```

Rever `VERSION` e `VCPKG_COMMIT_ID` em `novadx-windows.yml` face ao `flutter-build.yml` da nova tag.

## Licença

AGPL-3.0, como o projeto original. O código-fonte desta versão está neste repositório.
