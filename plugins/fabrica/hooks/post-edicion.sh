#!/usr/bin/env bash
# PostToolUse: formatea/lintea el archivo editado. No bloquea; informa a Claude si hay errores.
input="$(cat)"
f="$(jq -r '.tool_input.file_path // ""' <<<"$input")"
[[ -z "$f" || ! -f "$f" ]] && exit 0
case "$f" in
  *.py) command -v ruff >/dev/null && { ruff format -q "$f"; ruff check -q "$f" >&2 || exit 2; } ;;
  *.ts|*.tsx|*.js|*.jsx) [[ -x node_modules/.bin/eslint ]] && { node_modules/.bin/eslint --fix "$f" >&2 || exit 2; } ;;
esac
exit 0
