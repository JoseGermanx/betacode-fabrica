<!-- fabrica-version: 1.3.0 — archivo gestionado por el plugin fabrica; no editar a mano (se sobrescribe al actualizar) -->
# Fábrica de software (Betacode)

Este repositorio funciona como una **fábrica de software basada en agentes**. Cada cambio pasa por 7 fases y cada artefacto se revisa antes de avanzar. Las tareas simples pueden ir por un **carril rápido** que consolida las fases.

## Fuente de verdad
- **Tickets = GitHub Issues.** La fase actual es la etiqueta `fase:*` del issue.
- **Artefactos** de cada issue viven en `docs/specs/issue-<N>/` en la rama `fabrica/<N>`:
  `requisitos.md` → `diseno.md` → `plan.md` → código + PR.
- **Base de conocimiento** (leer SIEMPRE antes de trabajar): `docs/conocimiento/`
  - `estandares.md` — convenciones de código
  - `seguridad.md` — políticas de seguridad (no negociables)
  - `definicion-de-hecho.md` — criterios para dar algo por terminado

## Fases
| # | Fase | Etiqueta | Skill | Agente principal | Salida |
|---|------|----------|-------|------------------|--------|
| 1 | Requisitos | `fase:requisitos` | `/fabrica:requisitos N` | analista-requisitos | requisitos.md |
| 2 | Diseño | `fase:diseno` | `/fabrica:diseno N` | arquitecto | diseno.md |
| 3 | Plan | `fase:plan` | `/fabrica:plan N` | planificador | plan.md + sub-issues |
| 4 | Build | `fase:build` | `/fabrica:construir N` | implementador | commits + PR |
| 5 | Verificación | (CI + `/verificar N`) | `/fabrica:verificar N` | verificador | informe en el PR |
| 6 | Despliegue | merge a `main` | — (pipeline determinista) | — | producción |
| 7 | Operaciones | `fase:triage` | `/fabrica:triage N` | operaciones | diagnóstico + nuevo issue |

## Carril rápido (tareas simples)

Para tareas simples (landing, script, CRUD básico) usa `/fabrica:simple N` o la etiqueta `fase:simple`: consolida requisitos + diseño + plan + build en un solo paso, revisa con el agente ligero `revisor-rapido` (sonnet) y abre el PR.

- Un solo artefacto: `docs/specs/issue-<N>/plan.md` con los requisitos embebidos (sin `diseno.md`).
- Revisión ligera, máximo 1 ronda de corrección por artefacto.
- Si el riesgo es `alto` (auth, pagos, datos personales, migraciones destructivas, infraestructura, `.github/`), NO uses este carril: ve por `fase:requisitos`.

## Reglas de la fábrica
1. **Bucle de revisión obligatorio**: requisitos y diseño los revisa `revisor-opus`; plan y verificación, `revisor` (sonnet); con `riesgo: alto`, usa `revisor-opus`. El código de build lo revisa el PR (`revision-pr.yml`), no la fase. En el carril rápido, `revisor-rapido`. Máximo **2 iteraciones** de corrección (1 en requisitos y en el carril rápido); si sigue fallando, escalar a humano.
2. **Estado para el pipeline**: al terminar una fase escribe `.fabrica/estado.json`:
   `{"issue": N, "fase": "requisitos", "resultado": "ok" | "escalar", "riesgo": "bajo" | "medio" | "alto", "motivo": "..."}`
   El workflow (no tú) decide el siguiente paso leyendo este archivo.
3. **Riesgo alto** (auth, pagos, datos personales, migraciones destructivas, infraestructura, cambios en `.github/`) ⇒ `riesgo: "alto"`. Un humano debe aprobar.
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
