---
name: plan
description: Fase 3 de la fábrica: descompone diseno.md en tareas atómicas (plan.md) y crea sub-issues.
argument-hint: <número de issue>
---
# Fase: plan — issue #$ARGUMENTS

1. Lee `requisitos.md` y `diseno.md`.
2. Usa el subagente **planificador** para producir `plan.md`.
3. Tras aprobar el revisor, crea una casilla de verificación por tarea en un comentario del issue (o sub-issues si son > 8 tareas).

## Reglas de ejecución
Aplican las "Reglas de ejecución de cada fase" de `docs/conocimiento/fabrica.md`: agentes en primer plano, cada ronda es un Agent nuevo, sin comandos en segundo plano, y escribe `.fabrica/estado.json` antes de cerrar.

## Bucle de revisión (obligatorio)
1. Lanza el subagente **revisor** (plugin fabrica) sobre el artefacto producido. Si el `riesgo` del issue es `alto`, usa **revisor-opus** en su lugar.
2. Si el veredicto es CAMBIOS: lanza un Agent **nuevo** del subagente **planificador** con los hallazgos literales para corregir, y luego un revisor **nuevo**. Máximo 2 rondas.
3. Si tras 2 rondas sigue en CAMBIOS ⇒ `resultado: "escalar"` y comenta en el issue los hallazgos pendientes.

## Cierre
- Commit y push a la rama `fabrica/$ARGUMENTS` (créala desde `main` si no existe). Nunca a `main`.
- Comenta en el issue: resumen de 5 líneas + enlace al artefacto + veredicto del revisor.
- Escribe `.fabrica/estado.json` (formato en CLAUDE.md) con `"fase": "plan"`. No lo commitees.
