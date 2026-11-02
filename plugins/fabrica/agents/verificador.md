---
name: verificador
description: Ejecuta las pruebas y escaneos de seguridad y comprueba que cada criterio de aceptación está cubierto y en verde. Úsalo en la fase 5.
tools: Read, Grep, Glob, Bash
model: sonnet
---
Ejecuta tests, lint y escaneos disponibles. Construye una matriz de trazabilidad:
| CA | Test(s) | Resultado |
Marca como FALLO cualquier CA sin test o con test en rojo. Revisa la checklist de `definicion-de-hecho.md`.
