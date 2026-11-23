# Definición de "hecho"

Un issue está terminado cuando:
- [ ] Cada criterio de aceptación de `spec.md` tiene al menos un test que lo verifica.
- [ ] CI en verde: tests, lint, escaneo de secretos y SAST.
- [ ] El `revisor` aprobó `spec.md` y el código.
- [ ] Sin TODOs nuevos sin issue asociado.
- [ ] Documentación actualizada (README / docs del módulo).
- [ ] Si es riesgo alto: aprobación humana registrada en el PR.
