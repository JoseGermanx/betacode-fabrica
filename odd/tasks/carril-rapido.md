# Carril rápido para tareas simples

Objetivo: añadir un carril rápido a la fábrica para que tareas simples (p. ej. una landing) no pasen por las 7 fases con revisor opus en cada artefacto.
Rama: `feat/carril-rapido` · Estrategia de entrega: ask-on-risk · Test runner: ninguno aplicable (markdown/sh/yaml del plugin).

## Specs

- S1 — Carril por complejidad: añadir una vía rápida que se dispare con una etiqueta propia y consolide requisitos + diseño + plan en un solo artefacto. "carril rápido".
- S2 — Revisor por nivel: el revisor del carril rápido usa un modelo ligero (sonnet); opus queda para el flujo estándar/riesgo alto. "revisor por nivel".
- S3 — Fases colapsadas: para tareas simples no hay fase de diseño independiente ni revisión opus por artefacto; se llega a PR en un solo paso. "colapsar requisitos+diseño+plan en un solo artefacto".
- S4 — Landing es un ejemplo, no el alcance: se toma como caso de uso a incluir/mejorar más adelante junto a otros casos sencillos; este cambio no crea un skill dedicado a landing. "El caso de las landing fue un ejemplo nada mas, que podemos tomar para incluirlo y mejorarlo mas adelante asi como otros tipos de casos sencillos".

## Tasks

- T1 — Agente `revisor-rapido` (sonnet) para revisar plan y código de tareas simples. Ruta: inline. Estado: pendiente.
- T2 — Skill `simple`: consolida requisitos+diseño+plan+build en un paso y abre el PR. Ruta: inline. Estado: pendiente.
- T3 — Etiqueta `fase:simple` en `crear-etiquetas.sh`. Ruta: inline. Estado: pendiente.
- T4 — Mapeo `fase:simple → skill=simple` en `fabrica.yml`. Ruta: inline. Estado: pendiente.
- T5 — Docs y versión: `fabrica.md` (tabla + reglas + versión 1.3.0), `plugin.json` (1.3.0), `README.md` (nota del carril). Ruta: inline. Estado: pendiente.

## Log

- L1 (2026-11-03): "vamos a revisar las skills y pasos de este plugin para encontrar mejoras que hagan que para tareas que no sean tan complejas como por ejemplo hacer una landing page, el proceso sea mas rápido"
- L2 (2026-11-03): "Dale con la primera propuesta, carril. El caso de las landing fue un ejemplo nada mas, que podemos tomar para incluirlo y mejorarlo mas adelante asi como otros tipos de casos sencillos"
- L3 (2026-11-03): Decisión de diseño: la vía rápida se dispara con la etiqueta `fase:simple` (no con una etiqueta de complejidad separada) y ejecuta un único skill `simple` que abre el PR. El revisor del carril es `revisor-rapido` (sonnet). La revisión final del PR (`revision-pr.yml`) mantiene `revisor` (opus) como puerta de calidad deliberada.
