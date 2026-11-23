---
name: spec
description: Fase 1 de la fábrica: convierte un issue en spec.md (requisitos, riesgo, diseño proporcional y plan de tareas) con un único bucle de revisión adaptado al riesgo.
argument-hint: <número de issue>
---
# Fase: spec — issue #$ARGUMENTS

1. `gh issue view $ARGUMENTS --comments` para leer la solicitud completa.
2. Usa el subagente **especificador** para producir `docs/specs/issue-$ARGUMENTS/spec.md`.
3. Si hay preguntas abiertas que bloquean la implementación, publícalas en el issue y marca `resultado: "escalar"`.

## Reglas de ejecución
Aplican las "Reglas de ejecución de cada fase" de `docs/conocimiento/fabrica.md`: agentes en primer plano, cada ronda es un Agent nuevo, sin comandos en segundo plano, y escribe `.fabrica/estado.json` antes de cerrar.

## Bucle de revisión (obligatorio, adaptado al riesgo)
Elige el revisor y el máximo de rondas según el `riesgo` declarado en `spec.md`:
- `riesgo: bajo` → **revisor-rapido** (máximo 1 ronda).
- `riesgo: medio` → **revisor** (máximo 2 rondas).
- `riesgo: alto` → **revisor-opus** (máximo 2 rondas).

1. Lanza el subagente revisor correspondiente sobre `docs/specs/issue-$ARGUMENTS/spec.md`.
2. Si el veredicto es CAMBIOS: lanza un Agent **nuevo** del subagente **especificador** con los hallazgos literales para corregir, y luego un revisor **nuevo** del mismo tipo.
3. Si tras el máximo de rondas sigue en CAMBIOS ⇒ `resultado: "escalar"` y comenta en el issue los hallazgos pendientes.

## Cierre
- Tras aprobar el revisor, publica una casilla de verificación por tarea en un comentario del issue (o sub-issues si son > 8 tareas).
- Commit y push a la rama `fabrica/$ARGUMENTS` (créala desde `main` si no existe). Nunca a `main`.
- Comenta en el issue: resumen de 5 líneas + enlace al artefacto + veredicto del revisor.
- Escribe `.fabrica/estado.json` (formato en CLAUDE.md) con `"fase": "spec"`. No lo commitees.
