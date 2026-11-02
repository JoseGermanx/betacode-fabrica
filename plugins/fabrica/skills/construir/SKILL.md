---
name: construir
description: Fase 4 de la fábrica: implementa plan.md con TDD, un commit por tarea, y abre el PR.
argument-hint: <número de issue>
---
# Fase: build — issue #$ARGUMENTS

1. Lee `plan.md`. Usa el subagente **implementador** para ejecutar las tareas en orden.
2. Ejecuta la suite completa de tests al final.
3. El revisor revisa el diff completo (`git diff main...HEAD`).
4. Abre un PR `fabrica/$ARGUMENTS` → `main` con: `Closes #$ARGUMENTS`, tabla CA→tests, riesgo, y el veredicto del revisor.

## Bucle de revisión (obligatorio)
1. Lanza el subagente **revisor** (plugin fabrica) sobre el artefacto producido.
2. Si el veredicto es CAMBIOS: corrige con el subagente **implementador** y vuelve a revisar. Máximo 2 rondas.
3. Si tras 2 rondas sigue en CAMBIOS ⇒ `resultado: "escalar"` y comenta en el issue los hallazgos pendientes.

## Cierre
- Commit y push a la rama `fabrica/$ARGUMENTS` (créala desde `main` si no existe). Nunca a `main`.
- Comenta en el issue: resumen de 5 líneas + enlace al artefacto + veredicto del revisor.
- Escribe `.fabrica/estado.json` (formato en CLAUDE.md) con `"fase": "build"`. No lo commitees.
