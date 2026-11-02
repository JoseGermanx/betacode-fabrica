#!/usr/bin/env bash
# Fase 7: comprueba URLs de producción; si una falla 2 veces seguidas abre un issue de incidente
# (que dispara automáticamente al agente de operaciones vía la etiqueta fase:triage).
# Uso (cron): REPO=usuario/repo URLS_FILE=~/urls.txt ~/monitor.sh
set -uo pipefail
REPO="${REPO:?define REPO=usuario/repo}"
URLS_FILE="${URLS_FILE:-$HOME/urls.txt}"     # una URL por línea
STATE_DIR="$HOME/.monitor"; mkdir -p "$STATE_DIR"

while read -r url; do
  [[ -z "$url" || "$url" == \#* ]] && continue
  key=$(echo -n "$url" | md5sum | cut -c1-12)
  code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 15 "$url")
  t=$(curl -s -o /dev/null -w '%{time_total}' --max-time 15 "$url")
  if [[ "$code" =~ ^(2|3) ]]; then rm -f "$STATE_DIR/$key"; continue; fi

  fails=$(( $(cat "$STATE_DIR/$key" 2>/dev/null || echo 0) + 1 )); echo $fails > "$STATE_DIR/$key"
  [[ $fails -ne 2 ]] && continue           # solo al 2º fallo consecutivo, y una vez

  titulo="Incidente: $url responde $code"
  if gh issue list -R "$REPO" --label incidente --state open --search "in:title \"$url\"" --json number -q '.[0].number' | grep -q .; then
    continue                                 # ya hay un incidente abierto para esta URL
  fi
  gh issue create -R "$REPO" --title "$titulo" --label incidente --label fase:triage --body \
"Detectado por monitor.sh en $(hostname) el $(date -Is).
- URL: $url
- HTTP: $code
- Tiempo: ${t}s
- Fallos consecutivos: $fails"
  [[ -n "${N8N_WEBHOOK:-}" ]] && curl -fsS -X POST "$N8N_WEBHOOK" -H 'Content-Type: application/json' \
    -d "{\"tipo\":\"incidente\",\"url\":\"$url\",\"http\":\"$code\"}" >/dev/null || true
done < "$URLS_FILE"
