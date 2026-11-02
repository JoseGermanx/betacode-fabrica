# Políticas de seguridad (no negociables)

1. Ningún secreto en el repositorio (`.env`, claves, tokens). Usar GitHub Secrets / variables del servidor.
2. Validar y sanear toda entrada externa (formularios, webhooks, query params).
3. Consultas SQL parametrizadas siempre.
4. Datos personales (Ley 21.719 Chile / clientes EE.UU.): minimizar, no registrar en logs, cifrar en tránsito.
5. Dependencias nuevas: justificar en `diseno.md`; sin paquetes abandonados o con vulnerabilidades conocidas.
6. Webhooks: verificar firma (p. ej. Meta `X-Hub-Signature-256`).
7. Cambios en autenticación, pagos, permisos, infraestructura o `.github/` ⇒ riesgo ALTO ⇒ aprobación humana.
