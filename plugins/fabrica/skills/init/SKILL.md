---
name: init
description: Prepara un repositorio para la fábrica de software — clona un repo existente o crea uno nuevo en ~/repos, instala la fábrica según su estado (nuevo, con código, con CLAUDE.md propio o ya instalada) y abre una sesión dedicada. Úsalo cuando el usuario pida clonar, crear, adoptar o "meter a la fábrica" un proyecto.
argument-hint: <url | usuario/repo | nuevo <nombre> "descripción"> [--ci]
---
# /fabrica:init $ARGUMENTS

Objetivo: dejar el repo listo para usar `/fabrica:requisitos N` y el resto de fases, sin romper nada de lo que ya existe.
Los repos viven en `~/repos/<nombre>`. El copiado de archivos lo hace un **script determinista**; tú solo haces las partes que requieren criterio.

## 1. Obtener el repo
Interpreta `$ARGUMENTS`:
- **URL o `usuario/repo`** → si `~/repos/<nombre>` no existe: `gh repo clone <repo> ~/repos/<nombre>`. Si ya existe: `git -C ~/repos/<nombre> pull --ff-only` (si hay cambios locales sin commitear, detente y avisa).
- **`nuevo <nombre> "descripción"`** → `mkdir -p ~/repos/<nombre> && git -C ~/repos/<nombre> init -b main`. No crees aún el remoto.
- Si es ambiguo (no sabes si es nuevo o existente, o falta el nombre), pregunta antes de hacer nada.

En adelante trabaja SIEMPRE con rutas absolutas dentro de `~/repos/<nombre>` (o `git -C`), porque la sesión actual puede estar en otra carpeta.

## 2. Instalar (determinista)
```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/instalar.sh" ~/repos/<nombre> [--ci]
```
Usa `--ci` solo si el usuario lo pidió (instala workflows de GitHub, que necesitan secrets y runner).
Lee el bloque `=== RESULTADO ===` y actúa según `modo` y `claude_md`.

## 3. Ajuste con criterio según el caso

| modo / claude_md | Qué hacer |
|---|---|
| `nuevo` | Completa `CLAUDE.md` con lo que sepas de la descripción (propósito, stack previsto). Deja los comandos marcados como pendientes: se definirán en el primer issue. |
| `existente` + `creado` | Analiza el código (estructura, manifiestos de `stack_detectado`, scripts de package.json, CI existente) y **completa todas las secciones `<!-- COMPLETAR -->`** de `CLAUDE.md` con datos reales. Ejecuta una vez el comando de tests para verificarlo; si no hay tests, escríbelo explícitamente ("Sin tests todavía"). |
| `existente` + `import_agregado` | Lee el `CLAUDE.md` existente y compáralo con `docs/conocimiento/estandares.md` y `seguridad.md`. Para cada contradicción, **manda el CLAUDE.md del proyecto**: edita `estandares.md` para alinearlo o quitar lo que choque. Si al CLAUDE.md le faltan los comandos de tests/lint, agrégalos tras verificarlos. |
| `actualizacion` | Solo se actualizó `fabrica.md`. Resume qué cambió (`git diff docs/conocimiento/fabrica.md`). |
| `ya_instalada` | No hay nada que hacer; informa y pasa al paso 5. |

Revisa también `omitidos_ya_existian`: si el proyecto ya tenía archivos con esos nombres (p. ej. su propio `.github/workflows/ci.yml`), no los toques y avísalo.
Si el repo ya tenía `.claude/agents` o `.claude/skills` propios, comprueba que no haya nombres que confundan con los del plugin y menciónalo.

## 4. Guardar los cambios
- **Repo nuevo:**
  `git -C <dir> add -A && git -C <dir> commit -m "chore: proyecto inicial con fábrica de software"`
  y luego `gh repo create <nombre> --private --source <dir> --push` (siempre privado salvo que el usuario diga lo contrario).
  Después crea el **issue #1** con la descripción del proyecto como solicitud (`gh issue create --label fase:requisitos ...`): la estructura inicial del proyecto también pasa por la fábrica.
- **Repo existente:** rama `fabrica/instalacion`, commit `chore: instalar fábrica de software`, push de la rama y PR con un resumen de lo hecho y de las contradicciones encontradas. Nunca a `main` directamente.

## 5. Sesión dedicada (para el móvil)
Si existe la sesión tmux `claude` (servidor de la fábrica), abre una ventana para el proyecto con Remote Control:
```bash
tmux has-session -t claude 2>/dev/null && \
  tmux new-window -t claude -n "<nombre>" -c ~/repos/<nombre> "claude remote-control"
```
Así aparecerá en la app de Claude como una sesión nueva, ya situada en el repo y con su `CLAUDE.md` cargado.

## 6. Informe final (corto)
- Repo y ruta, modo detectado y qué se creó, importó u omitió.
- Contradicciones resueltas o pendientes.
- PR o issue creado (enlace).
- Siguiente paso: "abre la sesión `<nombre>` en la app y ejecuta `/fabrica:requisitos <N>`".
