---
name: requisitos
description: Fase 1 de la fábrica: convierte un issue en requisitos.md con criterios de aceptación verificables.
argument-hint: <número de issue>
---
# Fase: requisitos — issue #$ARGUMENTS

1. `gh issue view $ARGUMENTS --comments` para leer la solicitud completa.
2. Usa el subagente **analista-requisitos** para producir `docs/specs/issue-$ARGUMENTS/requisitos.md`.
3. Si hay preguntas abiertas que bloquean el diseño, publícalas en el issue y marca `resultado: "escalar"`.

## Reglas de ejecución
Aplican las "Reglas de ejecución de cada fase" de `docs/conocimiento/fabrica.md`: agentes en primer plano, cada ronda es un Agent nuevo, sin comandos en segundo plano, y escribe `.fabrica/estado.json` antes de cerrar.

## Bucle de revisión (obligatorio)
1. Lanza el subagente **revisor-opus** (plugin fabrica) sobre el artefacto producido.
2. Si el veredicto es CAMBIOS: lanza un Agent **nuevo** del subagente **analista-requisitos** con los hallazgos literales para corregir, y luego un **revisor-opus** nuevo. Máximo 1 ronda.
3. Si tras 1 ronda sigue en CAMBIOS ⇒ `resultado: "escalar"` y comenta en el issue los hallazgos pendientes.

## Cierre
- Commit y push a la rama `fabrica/$ARGUMENTS` (créala desde `main` si no existe). Nunca a `main`.
- Comenta en el issue: resumen de 5 líneas + enlace al artefacto + veredicto del revisor.
- Escribe `.fabrica/estado.json` (formato en CLAUDE.md) con `"fase": "requisitos"`. No lo commitees.
