---
name: diseno
description: Fase 2 de la fábrica: produce diseno.md (esquemas, contratos de API, seguridad, estrategia de pruebas) desde requisitos aprobados.
argument-hint: <número de issue>
---
# Fase: diseno — issue #$ARGUMENTS

1. Lee `docs/specs/issue-$ARGUMENTS/requisitos.md` en la rama `fabrica/$ARGUMENTS`.
2. Usa el subagente **arquitecto** para producir `diseno.md` en la misma carpeta.

## Reglas de ejecución
Aplican las "Reglas de ejecución de cada fase" de `docs/conocimiento/fabrica.md`: agentes en primer plano, cada ronda es un Agent nuevo, sin comandos en segundo plano, y escribe `.fabrica/estado.json` antes de cerrar.

## Bucle de revisión (obligatorio)
1. Lanza el subagente **revisor-opus** (plugin fabrica) sobre el artefacto producido.
2. Si el veredicto es CAMBIOS: lanza un Agent **nuevo** del subagente **arquitecto** con los hallazgos literales para corregir, y luego un **revisor-opus** nuevo. Máximo 2 rondas.
3. Si tras 2 rondas sigue en CAMBIOS ⇒ `resultado: "escalar"` y comenta en el issue los hallazgos pendientes.

## Cierre
- Commit y push a la rama `fabrica/$ARGUMENTS` (créala desde `main` si no existe). Nunca a `main`.
- Comenta en el issue: resumen de 5 líneas + enlace al artefacto + veredicto del revisor.
- Escribe `.fabrica/estado.json` (formato en CLAUDE.md) con `"fase": "diseno"`. No lo commitees.
