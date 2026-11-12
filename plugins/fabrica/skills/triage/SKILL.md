---
name: triage
description: Fase 7 de la fábrica: diagnostica un incidente de producción y genera un ticket de corrección.
argument-hint: <número de issue>
---
# Fase: operaciones — issue #$ARGUMENTS

1. Lee el issue de incidente y sus datos adjuntos.
2. Usa el subagente **operaciones** para diagnosticar.
3. Si la corrección es clara, crea un issue nuevo con la etiqueta `fase:requisitos` enlazado al incidente.

## Reglas de ejecución
Aplican las "Reglas de ejecución de cada fase" de `docs/conocimiento/fabrica.md`: agentes en primer plano, cada ronda es un Agent nuevo, sin comandos en segundo plano, y escribe `.fabrica/estado.json` antes de cerrar.

## Bucle de revisión (obligatorio)
1. Lanza el subagente **revisor** (plugin fabrica) sobre el artefacto producido.
2. Si el veredicto es CAMBIOS: lanza un Agent **nuevo** del subagente **operaciones** con los hallazgos literales para corregir, y luego un revisor **nuevo**. Máximo 2 rondas.
3. Si tras 2 rondas sigue en CAMBIOS ⇒ `resultado: "escalar"` y comenta en el issue los hallazgos pendientes.

## Cierre
- Commit y push a la rama `fabrica/$ARGUMENTS` (créala desde `main` si no existe). Nunca a `main`.
- Comenta en el issue: resumen de 5 líneas + enlace al artefacto + veredicto del revisor.
- Escribe `.fabrica/estado.json` (formato en CLAUDE.md) con `"fase": "operaciones"`. No lo commitees.
