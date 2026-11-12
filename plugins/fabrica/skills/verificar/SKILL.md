---
name: verificar
description: Fase 5 de la fábrica: verifica que cada criterio de aceptación tiene tests en verde y que pasan los escaneos de seguridad.
argument-hint: <número de issue>
---
# Fase: verificacion — issue #$ARGUMENTS

1. Usa el subagente **verificador** para construir la matriz CA→test→resultado a partir de los resultados de CI (`ci.yml`), sin re-ejecutar la suite completa.
2. Publica la matriz como comentario en el PR del issue.

## Reglas de ejecución
Aplican las "Reglas de ejecución de cada fase" de `docs/conocimiento/fabrica.md`: agentes en primer plano, cada ronda es un Agent nuevo, sin comandos en segundo plano, y escribe `.fabrica/estado.json` antes de cerrar.

## Bucle de revisión (obligatorio)
1. Lanza el subagente **revisor** (plugin fabrica) sobre el artefacto producido. Si el `riesgo` del issue es `alto`, usa **revisor-opus** en su lugar.
2. Si el veredicto es CAMBIOS: lanza un Agent **nuevo** del subagente **verificador** con los hallazgos literales para corregir, y luego un revisor **nuevo**. Máximo 2 rondas.
3. Si tras 2 rondas sigue en CAMBIOS ⇒ `resultado: "escalar"` y comenta en el issue los hallazgos pendientes.

## Cierre
- Commit y push a la rama `fabrica/$ARGUMENTS` (créala desde `main` si no existe). Nunca a `main`.
- Comenta en el issue: resumen de 5 líneas + enlace al artefacto + veredicto del revisor.
- Escribe `.fabrica/estado.json` (formato en CLAUDE.md) con `"fase": "verificacion"`. No lo commitees.
