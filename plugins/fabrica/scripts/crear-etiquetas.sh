#!/usr/bin/env bash
# Crea las etiquetas de la fábrica en un repo.  Uso: ./scripts/crear-etiquetas.sh usuario/repo
set -euo pipefail
R="${1:?usuario/repo}"
while IFS='|' read -r n c d; do
  gh label create "$n" -R "$R" --color "$c" --description "$d" --force
done <<'L'
fase:requisitos|1D76DB|Fase 1: analista convierte la solicitud en requisitos
fase:diseno|5319E7|Fase 2: arquitecto produce el diseño técnico
fase:plan|0E8A16|Fase 3: planificador descompone en tareas
fase:build|FBCA04|Fase 4: implementador escribe código y abre PR
fase:simple|9C4F96|Carril rápido: requisitos+diseño+plan+build en un solo paso para tareas simples
fase:triage|B60205|Fase 7: agente de operaciones diagnostica
incidente|D93F0B|Incidente de producción
esperando-aprobacion|C5DEF5|Puerta humana: añade la siguiente fase para continuar
escalado-humano|000000|El bucle de revisión falló 2 veces o faltan datos
L
