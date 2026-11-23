<!-- fabrica-version: 2.0.0 — archivo gestionado por el plugin fabrica; no editar a mano (se sobrescribe al actualizar) -->
# Fábrica de software (Betacode)

Este repositorio funciona como una **fábrica de software basada en agentes** con un único carril de 5 fases. El rigor de la especificación, del revisor y de las puertas humanas se adapta automáticamente al **riesgo** de cada cambio.

## Fuente de verdad
- **Tickets = GitHub Issues.** La fase actual es la etiqueta `fase:*` del issue.
- **Artefactos** de cada issue viven en `docs/specs/issue-<N>/` en la rama `fabrica/<N>`:
  `spec.md` → código + PR.
- **Base de conocimiento** (leer SIEMPRE antes de trabajar): `docs/conocimiento/`
  - `estandares.md` — convenciones de código
  - `seguridad.md` — políticas de seguridad (no negociables)
  - `definicion-de-hecho.md` — criterios para dar algo por terminado

## Fases
| # | Fase | Etiqueta | Skill | Agente principal | Salida |
|---|------|----------|-------|------------------|--------|
| 1 | Spec | `fase:spec` | `/fabrica:spec N` | especificador | `spec.md` + checklist/sub-issues |
| 2 | Build | `fase:build` | `/fabrica:construir N` | implementador | commits + PR |
| 3 | Verificación | (CI + `/verificar N`) | `/fabrica:verificar N` | verificador | informe en el PR |
| 4 | Despliegue | merge a `main` | — (pipeline determinista) | — | producción |
| 5 | Operaciones | `fase:triage` | `/fabrica:triage N` | operaciones | diagnóstico + nuevo issue |

## Reglas de la fábrica
1. **Bucle de revisión obligatorio (adaptado al riesgo)**:
   - En `spec`: `riesgo: bajo` usa `revisor-rapido` (máx. **1 iteración**); `riesgo: medio` usa `revisor` (máx. **2 iteraciones**); `riesgo: alto` usa `revisor-opus` (máx. **2 iteraciones**).
   - En `verificacion` y `operaciones`: usa `revisor` (o `revisor-opus` si `riesgo: alto`), máx. **2 iteraciones**.
   - El código de `build` lo revisa el PR (`revision-pr.yml`), no la fase.
   - Si tras el máximo de iteraciones sigue fallando, escalar a humano.
2. **Estado para el pipeline**: al terminar una fase escribe `.fabrica/estado.json`:
   `{"issue": N, "fase": "spec", "resultado": "ok" | "escalar", "riesgo": "bajo" | "medio" | "alto", "motivo": "..."}`
   El workflow (no tú) decide el siguiente paso leyendo este archivo.
3. **Riesgo alto** (auth, pagos, datos personales, migraciones destructivas, infraestructura, cambios en `.github/`) ⇒ `riesgo: "alto"`. Un humano debe aprobar antes de pasar a `fase:build`.
4. Nunca desplegar, nunca hacer push a `main`, nunca tocar secretos ni `.env`.
5. Si los requisitos son ambiguos, **pregunta en un comentario del issue** y marca `resultado: "escalar"`; no inventes.
6. Commits pequeños, mensaje convencional (`feat:`, `fix:`, `docs:`, `test:`), referenciando `#N`.

## Reglas de ejecución de cada fase
1. Cada subagente (autor, revisor o corrector) se lanza con la herramienta **Agent en primer plano**: nunca en segundo plano, y esperas su resultado antes de seguir.
2. **Cada ronda es un Agent nuevo**: nunca uses `SendMessage` para continuar un agente anterior. En el prompt de la ronda pasa la ruta del artefacto y los hallazgos del revisor **literales**.
3. El revisor de cada ronda también es una instancia nueva (independencia: no revisa con el contexto de la ronda anterior).
4. No uses comandos en segundo plano (`&`, `nohup`) ni esperes eventos externos.
5. **No cierres el turno sin haber escrito `.fabrica/estado.json`.** Es lo último que haces. Si algo falla, se agotan las rondas o no puedes terminar, escríbelo igual con `"resultado": "escalar"` y el motivo.

> Los comandos de instalación, tests y lint de este proyecto están en el `CLAUDE.md` raíz.
