#!/usr/bin/env bash
# PreToolUse: bloquea acciones peligrosas antes de que ocurran. exit 2 = bloquear (stderr vuelve a Claude).
set -euo pipefail
input="$(cat)"
tool="$(jq -r '.tool_name // ""' <<<"$input")"
cmd="$(jq -r '.tool_input.command // ""' <<<"$input")"
path="$(jq -r '.tool_input.file_path // ""' <<<"$input")"

block() { echo "BLOQUEADO por guardia.sh: $1" >&2; exit 2; }

if [[ "$tool" == "Bash" ]]; then
  [[ "$cmd" =~ rm[[:space:]]+-[a-zA-Z]*r[a-zA-Z]*f?[[:space:]]+(/|~|\$HOME|\*)([[:space:]]|$) ]] && block "borrado recursivo de raíz/home"
  [[ "$cmd" =~ git[[:space:]]+push.*(main|master)([[:space:]]|$) ]] && block "push directo a main: usa una rama fabrica/<N> y un PR"
  [[ "$cmd" =~ git[[:space:]]+push.*(--force|-f)([[:space:]]|$) ]] && block "force push no permitido"
  [[ "$cmd" =~ (cat|less|head|tail|cp|scp|curl).*\.env ]] && block "acceso a archivos .env"
  [[ "$cmd" =~ (DROP[[:space:]]+(TABLE|DATABASE)|TRUNCATE) ]] && block "SQL destructivo: requiere humano"
fi

if [[ "$tool" =~ ^(Edit|Write|MultiEdit)$ ]]; then
  [[ "$path" =~ (^|/)\.env ]] && block "edición de .env"
  es_fabrica=false; [[ -f "${CLAUDE_PROJECT_DIR:-.}/docs/conocimiento/fabrica.md" ]] && es_fabrica=true
  $es_fabrica && [[ "$path" =~ (^|/)\.github/ ]] && block "cambios en .github/ son riesgo alto: hazlos manualmente"
  [[ "$path" =~ \.(pem|key)$ ]] && block "archivo de clave"
fi
exit 0
