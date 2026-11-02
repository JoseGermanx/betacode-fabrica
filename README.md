# betacode-fabrica — Fábrica de software como plugin de Claude Code

Este repo es a la vez un **marketplace** y el **plugin `fabrica`**. Se instala una vez en el VPS (o en cualquier computadora) y desde ahí puedes adoptar cualquier proyecto con un solo comando:

```
/fabrica:init usuario/repo-existente
/fabrica:init https://github.com/usuario/proyecto-viejo.git
/fabrica:init nuevo landing-ferreteria "Landing para ferretería en Rancagua, Astro + formulario a n8n"
```

## Tres capas

```
┌─ 1. Base del VPS (una vez) ───────────────────────────────────────────────┐
│ ~/.claude/CLAUDE.md      reglas globales ("usa /fabrica:init", ~/repos)  │
│ ~/.claude/settings.json  marketplace + plugin activado + permisos        │
│ Plugin fabrica           agentes, skills, hooks, plantillas, instalador  │
│ tmux "claude"/lobby      sesión Remote Control siempre viva en ~/repos   │
└──────────────────────────────────────────────────────────────────────────┘
            │  "clona X y mételo a la fábrica"  (desde el móvil)
            ▼
┌─ 2. Bootstrap por repo: /fabrica:init ────────────────────────────────────┐
│ clona o crea → instalar.sh (determinista) → ajuste con criterio →        │
│ commit/PR → abre ventana tmux "<repo>" con Remote Control                 │
└──────────────────────────────────────────────────────────────────────────┘
            ▼
┌─ 3. Trabajo diario en la sesión del repo ────────────────────────────────┐
│ /fabrica:requisitos N → diseno → plan → construir → verificar             │
│ (o automático vía GitHub Actions si se instaló con --ci)                  │
└──────────────────────────────────────────────────────────────────────────┘
```

**¿Por qué un plugin y no copiar archivos?** Los agentes, skills y hooks viven en un solo lugar. Están disponibles en cualquier carpeta incluso antes de clonar nada, y se actualizan para todos los repos con `/plugin update`. En cada repo solo queda lo que es **propio del proyecto**: su `CLAUDE.md`, la base de conocimiento personalizable y los specs.

## Qué deja `/fabrica:init` en cada repo

| Archivo | Dueño | Comportamiento |
|---|---|---|
| `docs/conocimiento/fabrica.md` | plugin | Se sobrescribe al actualizar (lleva `fabrica-version`). |
| `docs/conocimiento/{estandares,seguridad,definicion-de-hecho}.md` | proyecto | Se copian solo si no existen; luego son tuyos. |
| `docs/specs/_plantillas/` | proyecto | Igual que el anterior. |
| `CLAUDE.md` | proyecto | Si no existe, se crea y el agente lo completa analizando el código. Si existe, solo se le **agrega** `@docs/conocimiento/fabrica.md`. |
| `.claude/settings.json` | proyecto | Se **combina** (jq): declara el marketplace y activa el plugin, sin tocar tus permisos. |
| `.gitignore` | proyecto | Agrega `.fabrica/estado.json`. |
| `.github/`, `scripts/deploy.sh` | proyecto | Solo con `--ci` y sin sobrescribir lo que ya tengas. |
| Etiquetas `fase:*` | GitHub | Se crean si el repo tiene remoto. |

### Casos que resuelve

| Caso | Detección | Qué hace |
|---|---|---|
| Proyecto **nuevo** | repo sin archivos | Crea `CLAUDE.md` y el repo privado en GitHub, y abre el **issue #1** con la descripción. Así la estructura inicial también pasa por la fábrica. |
| **Existente sin** CLAUDE.md | hay código | Analiza el stack y completa `CLAUDE.md` con comandos verificados. Lo entrega en el PR `fabrica/instalacion`. |
| **Existente con** CLAUDE.md | ya existe | Agrega el import y compara con `estandares.md`. Si chocan, **manda tu CLAUDE.md** y lo deja anotado en el PR. |
| **Ya instalada** | misma versión | No toca nada. |
| **Actualización** | versión distinta | Actualiza `fabrica.md` y resume qué cambió. |

## Instalación

1. **Publica este repo en GitHub** como `TU_USUARIO/betacode-fabrica`. Puede ser público porque no contiene secretos. Si lo haces privado, el VPS y los runners necesitarán `gh auth` con acceso a él.
2. **En el VPS:**
   ```bash
   git clone https://github.com/TU_USUARIO/betacode-fabrica && sudo bash betacode-fabrica/vps/setup.sh
   sudo -iu fabrica
   sed -i 's/TU_USUARIO/<tu-usuario>/g' ~/.claude/settings.json
   gh auth login && gh auth setup-git
   claude          # login → /plugin marketplace add <tu-usuario>/betacode-fabrica → /plugin install fabrica@betacode
   systemctl --user enable --now claude-remoto      # sesión lobby
   ```
3. **En tus computadoras locales:** dentro de Claude Code, ejecuta `/plugin marketplace add <tu-usuario>/betacode-fabrica` y luego `/plugin install fabrica@betacode`. Para usar `/fabrica:init` en local, define `FABRICA_MARKETPLACE_REPO` en tu `~/.claude/settings.json` (bloque `env`), igual que en el VPS.

## Uso desde el móvil

1. App Claude → **Code** → sesión *lobby* del VPS.
2. Escribe: *"Clona betacode/crm-whatsapp y mételo a la fábrica"* o *"Proyecto nuevo: landing para AFM, Astro"*.
3. Cuando termine, aparece una **sesión nueva con el nombre del repo**. Ábrela y trabaja con `/fabrica:requisitos N`, etc.
4. Revisa el PR `fabrica/instalacion` en la app de GitHub y haz merge.

## Actualizar la fábrica

1. Edita el plugin en este repo, sube `version` en `plugin.json` y `fabrica-version` en `plantilla/docs/conocimiento/fabrica.md`, y haz push.
2. En el VPS y en tus computadoras, ejecuta `/plugin marketplace update betacode`. Los agentes y skills nuevos quedan disponibles al instante en todos los repos.
3. En cada repo, `/fabrica:init <repo>` detecta `actualizacion` y refresca `fabrica.md`.

## Notas
- **Sesión lobby vs. sesión del repo:** Claude carga el `CLAUDE.md` y los settings de la carpeta donde **arranca**. Por eso `init` abre una ventana nueva en el repo en vez de trabajar desde el lobby.
- **Modo CI (`--ci`)**: los workflows cargan el plugin con `plugin_marketplaces` y `plugins` de `claude-code-action`. Define la variable `FABRICA_MARKETPLACE` en el repo o en la organización con la URL `.git` de este repo. Requisitos (secrets, runner, environment `produccion`): ver el kit anterior. Runners self-hosted, solo en repos privados.
- **Barandillas globales:** el hook del plugin bloquea en **todas** las sesiones el push a main, el force push, `.env` y el SQL destructivo. La restricción sobre `.github/` aplica solo en repos con la fábrica instalada. `init` crea el repo nuevo con `gh repo create --push`, que es el único push inicial a `main` permitido.
