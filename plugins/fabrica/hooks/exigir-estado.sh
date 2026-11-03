#!/usr/bin/env bash
# Stop hook: si hay una fase de la fábrica en curso (.fabrica/en-curso, lo crea el workflow),
# impide cerrar el turno hasta que exista un .fabrica/estado.json válido. exit 2 = "no pares, sigue".
# Máximo 3 bloqueos: después deja terminar y el workflow escala (falta estado = escalar).
D="${CLAUDE_PROJECT_DIR:-.}/.fabrica"
[[ -f "$D/en-curso" ]] || exit 0
if [[ -f "$D/estado.json" ]] && jq -e '.resultado and .fase and .riesgo' "$D/estado.json" >/dev/null 2>&1; then
  exit 0
fi
n=$(( $(cat "$D/.intentos-stop" 2>/dev/null || echo 0) + 1 )); echo $n > "$D/.intentos-stop"
[[ $n -gt 3 ]] && exit 0
echo "No cierres el turno: falta .fabrica/estado.json válido (fase: $(cat "$D/en-curso")). \
Si quedan rondas, termínalas con Agents nuevos en primer plano. Si no puedes completar, escribe \
{\"issue\":N,\"fase\":\"...\",\"resultado\":\"escalar\",\"riesgo\":\"alto\",\"motivo\":\"...\"} y termina." >&2
exit 2
