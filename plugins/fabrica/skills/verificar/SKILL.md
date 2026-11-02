---
name: verificar
description: Fase 5 de la fábrica: verifica que cada criterio de aceptación tiene tests en verde y que pasan los escaneos de seguridad.
argument-hint: <número de issue>
---
# Fase: verificacion — issue #$ARGUMENTS

1. Usa el subagente **verificador** para correr tests, lint y escaneos y construir la matriz CA→test→resultado.
2. Publica la matriz como comentario en el PR del issue.

## Bucle de revisión (obligatorio)
1. Lanza el subagente **revisor** (plugin fabrica) sobre el artefacto producido.
2. Si el veredicto es CAMBIOS: corrige con el subagente **verificador** y vuelve a revisar. Máximo 2 rondas.
3. Si tras 2 rondas sigue en CAMBIOS ⇒ `resultado: "escalar"` y comenta en el issue los hallazgos pendientes.

## Cierre
- Commit y push a la rama `fabrica/$ARGUMENTS` (créala desde `main` si no existe). Nunca a `main`.
- Comenta en el issue: resumen de 5 líneas + enlace al artefacto + veredicto del revisor.
- Escribe `.fabrica/estado.json` (formato en CLAUDE.md) con `"fase": "verificacion"`. No lo commitees.
