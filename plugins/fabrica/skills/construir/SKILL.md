---
name: construir
description: Fase 4 de la fábrica: implementa plan.md con TDD, un commit por tarea, y abre el PR.
argument-hint: <número de issue>
---
# Fase: build — issue #$ARGUMENTS

1. Lee `plan.md`. Usa el subagente **implementador** para ejecutar las tareas en orden.
2. Ejecuta la suite completa de tests UNA sola vez, al final (salida mínima, reporta solo fallos).
3. Abre un PR `fabrica/$ARGUMENTS` → `main` con: `Closes #$ARGUMENTS`, tabla CA→tests y riesgo. La revisión del código no se hace en esta fase: la hace `revision-pr.yml` al abrir el PR.

## Reglas de ejecución
Aplican las "Reglas de ejecución de cada fase" de `docs/conocimiento/fabrica.md`: agentes en primer plano, cada ronda es un Agent nuevo, sin comandos en segundo plano, y escribe `.fabrica/estado.json` antes de cerrar.

## Revisión del código (en el PR, no en esta fase)
La revisión del código la hace el workflow `revision-pr.yml` al abrir el PR, con el subagente **revisor** sobre `git diff main...HEAD`. No lances el revisor en esta fase. Si el PR pide cambios, lanza un Agent **nuevo** del subagente **implementador** con los hallazgos literales para corregir. Máximo 2 rondas; si sigue en CAMBIOS ⇒ `resultado: "escalar"` y comenta en el issue los hallazgos pendientes.

## Cierre
- Commit y push a la rama `fabrica/$ARGUMENTS` (créala desde `main` si no existe). Nunca a `main`.
- Comenta en el issue: resumen de 5 líneas + enlace al PR. El veredicto del revisor queda en la revisión del PR (`revision-pr.yml`).
- Escribe `.fabrica/estado.json` (formato en CLAUDE.md) con `"fase": "build"`. No lo commitees.
