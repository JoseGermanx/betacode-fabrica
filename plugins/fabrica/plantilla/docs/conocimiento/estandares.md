# Estándares de código

- Idioma: código y nombres en inglés; documentación y comentarios de negocio en español.
- Funciones pequeñas (< 40 líneas), una responsabilidad.
- Python: tipado (`typing`), `ruff` + `pytest`. Serverless: handlers delgados, lógica en módulos testeables.
- JS/TS: TypeScript estricto, `eslint`, tests con `vitest`/`jest`.
- Configuración por variables de entorno; nunca valores sensibles en el código.
- Toda función pública nueva lleva test. Todo bug corregido lleva test de regresión.
- APIs: contratos documentados (OpenAPI o tabla en `diseno.md`), errores con código y mensaje claros.
- Base de datos: migraciones versionadas y reversibles.
