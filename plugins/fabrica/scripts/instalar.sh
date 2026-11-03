#!/usr/bin/env bash
# Instalador DETERMINISTA de la fábrica en un repo. No hace commits: eso lo decide la skill /fabrica:init.
# Uso: instalar.sh <directorio-del-repo> [--ci]
#   --ci  copia también .github/ (workflows + plantillas de issues) y scripts/deploy.sh
# Nunca sobrescribe archivos del proyecto; solo actualiza docs/conocimiento/fabrica.md (propiedad del plugin).
set -euo pipefail
RAIZ_PLUGIN="$(cd "$(dirname "$0")/.." && pwd)"
PL="$RAIZ_PLUGIN/plantilla"
REPO="${1:?Uso: instalar.sh <dir> [--ci]}"; shift
CI=false; [[ "${1:-}" == "--ci" ]] && CI=true
cd "$REPO"
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "ERROR: $REPO no es un repo git"; exit 1; }

copiados=(); omitidos=()
copiar() { # origen relativo a plantilla -> mismo destino, sin sobrescribir
  local rel="$1"
  while IFS= read -r -d '' f; do
    local dst="${f#"$PL"/}"
    [[ "$dst" == "docs/conocimiento/fabrica.md" ]] && continue
    if [[ -e "$dst" ]]; then omitidos+=("$dst"); else mkdir -p "$(dirname "$dst")"; cp "$f" "$dst"; copiados+=("$dst"); fi
  done < <(find "$PL/$rel" -type f -print0)
}

# 1) Estado previo
version_nueva=$(grep -o 'fabrica-version: [0-9.]*' "$PL/docs/conocimiento/fabrica.md" | cut -d' ' -f2)
if [[ -f docs/conocimiento/fabrica.md ]]; then
  version_prev=$(grep -o 'fabrica-version: [0-9.]*' docs/conocimiento/fabrica.md | cut -d' ' -f2 || echo "?")
  modo=$([[ "$version_prev" == "$version_nueva" ]] && echo "ya_instalada" || echo "actualizacion")
else
  version_prev="-"
  n_archivos=$(git ls-files | wc -l)
  modo=$([[ $n_archivos -eq 0 ]] && echo "nuevo" || echo "existente")
fi

# 2) Archivo gestionado por el plugin: siempre a la última versión
mkdir -p docs/conocimiento
cp "$PL/docs/conocimiento/fabrica.md" docs/conocimiento/fabrica.md

# 3) Base de conocimiento y plantillas (sin sobrescribir lo que el proyecto ya personalizó)
copiar docs/conocimiento
copiar docs/specs/_plantillas
mkdir -p .fabrica && touch .fabrica/.gitkeep

# 4) CLAUDE.md
IMPORT='@docs/conocimiento/fabrica.md'
if [[ ! -f CLAUDE.md ]]; then
  sed "s/<NOMBRE_PROYECTO>/$(basename "$PWD")/" "$PL/CLAUDE.base.md" > CLAUDE.md
  claude_md="creado"
elif grep -qF "$IMPORT" CLAUDE.md; then
  claude_md="ya_importaba"
else
  printf '\n## Fábrica de software\nEste repo usa el flujo de agentes por fases. Reglas completas:\n%s\n' "$IMPORT" >> CLAUDE.md
  claude_md="import_agregado"
fi

# 5) .gitignore
touch .gitignore
for l in .fabrica/estado.json .fabrica/en-curso .fabrica/.intentos-stop; do
  grep -qxF "$l" .gitignore || echo "$l" >> .gitignore
done

# 6) .claude/settings.json del repo: declara el marketplace/plugin para cualquiera que abra el repo
MK="${FABRICA_MARKETPLACE_REPO:-}"
if [[ -n "$MK" ]]; then
  mkdir -p .claude; [[ -f .claude/settings.json ]] || echo '{}' > .claude/settings.json
  tmp=$(mktemp)
  jq --arg r "$MK" '.extraKnownMarketplaces.betacode = {"source":{"source":"github","repo":$r}}
                   | .enabledPlugins["fabrica@betacode"] = true' .claude/settings.json > "$tmp" && mv "$tmp" .claude/settings.json
  settings="actualizado"
else
  settings="omitido (define FABRICA_MARKETPLACE_REPO)"
fi

# 7) Modo CI
if $CI; then copiar .github; copiar scripts; chmod +x scripts/*.sh 2>/dev/null || true; fi

# 8) Etiquetas en GitHub (si hay remoto y gh autenticado)
etiquetas="omitidas"
if remoto=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null); then
  "$RAIZ_PLUGIN/scripts/crear-etiquetas.sh" "$remoto" >/dev/null 2>&1 && etiquetas="creadas en $remoto"
fi

# 9) Pistas del stack para que el agente complete CLAUDE.md
stack=()
for m in package.json pyproject.toml requirements.txt composer.json Gemfile go.mod Cargo.toml serverless.yml template.yaml Dockerfile docker-compose.yml wp-config.php; do
  [[ -n "$(find . -maxdepth 3 -name "$m" -not -path './node_modules/*' -print -quit)" ]] && stack+=("$m")
done
tiene_tests=$( [[ -n "$(find . -maxdepth 4 \( -name '*test*' -o -name '*spec*' \) -not -path './node_modules/*' -not -path './.git/*' -not -path './docs/*' -print -quit)" ]] && echo si || echo no )

cat <<RES
=== RESULTADO instalar.sh ===
modo: $modo
version: $version_prev -> $version_nueva
claude_md: $claude_md
settings_repo: $settings
ci: $CI
etiquetas: $etiquetas
stack_detectado: ${stack[*]:-ninguno}
tiene_tests: $tiene_tests
copiados: ${copiados[*]:-ninguno}
omitidos_ya_existian: ${omitidos[*]:-ninguno}
RES
