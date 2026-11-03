---
name: verificar
description: Fase 5 de la fábrica: verifica que cada criterio de aceptación tiene tests en verde y que pasan los escaneos de seguridad.
argument-hint: <número de issue>
---
# Fase: verificacion — issue #$ARGUMENTS

1. Usa el subagente **verificador** para correr tests, lint y escaneos y construir la matriz CA→test→resultado.
2. Publica la matriz como comentario en el PR del issue.

## Reglas de ejecución (obligatorias, en local y en CI)
1. Cada subagente (autor, revisor o corrector) se lanza con la herramienta **Agent en primer plano**: nunca con `run_in_background`, y esperas su resultado antes de seguir.
2. **Cada ronda es un Agent nuevo.** Nunca uses `SendMessage` para continuar un agente anterior. En el prompt de la ronda pasa la ruta del artefacto y los hallazgos del revisor **literales**.
3. El **revisor de cada ronda también es una instancia nueva** (independencia: no revisa con el contexto de la ronda anterior).
4. No uses comandos en segundo plano (`&`, `nohup`) ni esperes eventos externos.
5. **No cierres el turno sin haber escrito `.fabrica/estado.json`.** Es lo último que haces. Si algo falla, se agotan las rondas o no puedes terminar, escríbelo igual con `"resultado": "escalar"` y el motivo.

## Bucle de revisión (obligatorio)
1. Lanza el subagente **revisor** (plugin fabrica) sobre el artefacto producido.
2. Si el veredicto es CAMBIOS: lanza un Agent **nuevo** del subagente **verificador** con los hallazgos literales para corregir, y luego un revisor **nuevo**. Máximo 2 rondas.
3. Si tras 2 rondas sigue en CAMBIOS ⇒ `resultado: "escalar"` y comenta en el issue los hallazgos pendientes.

## Cierre
- Commit y push a la rama `fabrica/$ARGUMENTS` (créala desde `main` si no existe). Nunca a `main`.
- Comenta en el issue: resumen de 5 líneas + enlace al artefacto + veredicto del revisor.
- Escribe `.fabrica/estado.json` (formato en CLAUDE.md) con `"fase": "verificacion"`. No lo commitees.
