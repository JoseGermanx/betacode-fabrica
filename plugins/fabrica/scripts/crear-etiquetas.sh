#!/usr/bin/env bash
# Crea las etiquetas de la fábrica en un repo.  Uso: ./scripts/crear-etiquetas.sh usuario/repo
set -euo pipefail
R="${1:?usuario/repo}"
while IFS='|' read -r n c d; do
  gh label create "$n" -R "$R" --color "$c" --description "$d" --force
done <<'L'
fase:spec|1D76DB|Fase 1: especificador produce spec.md (requisitos, diseño y plan)
fase:build|FBCA04|Fase 2: implementador escribe código y abre PR
fase:triage|B60205|Fase 5: agente de operaciones diagnostica
incidente|D93F0B|Incidente de producción
esperando-aprobacion|C5DEF5|Puerta humana: añade la siguiente fase para continuar
escalado-humano|000000|El bucle de revisión falló 2 veces o faltan datos
L
