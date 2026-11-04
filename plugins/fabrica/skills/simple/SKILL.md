---
name: simple
description: Carril rápido de la fábrica para tareas simples (landing, script, CRUD básico). Consolida requisitos + diseño + plan + build en un solo paso, con un revisor ligero, y abre el PR. Úsalo cuando el usuario pida algo sencillo o etiquete el issue como fase:simple.
argument-hint: <número de issue>
---
# /fabrica:simple $ARGUMENTS — carril rápido

Para tareas simples no hay fase de diseño ni revisión opus por artefacto: se produce un único `plan.md` con los requisitos embebidos y se llega a PR en un solo paso.

## 1. Entender la solicitud
`gh issue view $ARGUMENTS --comments` para leer la solicitud completa y su alcance.

## 2. Plan consolidado (lo escribes tú, inline)
Escribe `docs/specs/issue-$ARGUMENTS/plan.md` con:
- **Objetivo**: 2-3 líneas.
- **Alcance**: incluye / no incluye.
- **Criterios de aceptación**: CA1..n, formato Dado/Cuando/Entonces, verificables por test.
- **Riesgo**: `bajo|medio|alto` según `docs/conocimiento/seguridad.md` punto 7.
- **Tareas**: tabla T1..n (ID, tarea atómica, CA cubiertos, archivos).
- **Preguntas abiertas**: si falta algo imprescindible, NO lo inventes; publícalo en el issue y marca `resultado: "escalar"`.

**Guardia de riesgo**: si el riesgo es `alto` (auth, pagos, datos personales, migraciones destructivas, infraestructura, `.github/`), NO uses este carril. Detente con `resultado: "escalar"` y avisa que el issue debe ir por el flujo estándar (`fase:requisitos`).

## 3. Revisar el plan
Lanza el subagente **revisor-rapido** sobre `plan.md`. Si CAMBIOS: corrige tú el plan y lanza un revisor-rapido **nuevo**. Máximo 1 ronda; si sigue en CAMBIOS ⇒ `resultado: "escalar"`.

## 4. Implementar
Lanza el subagente **implementador** para ejecutar las tareas en orden (TDD, un commit por tarea).

## 5. Verificar
Ejecuta la suite completa de tests del proyecto (ver `CLAUDE.md`). Si falla, corrige.

## 6. Revisar el código
Lanza el subagente **revisor-rapido** sobre `git diff main...HEAD`. Si CAMBIOS: lanza un implementador **nuevo** con los hallazgos literales, luego un revisor-rapido **nuevo**. Máximo 1 ronda; si sigue ⇒ `resultado: "escalar"`.

## 7. Abrir el PR
PR `fabrica/$ARGUMENTS` → `main` con: `Closes #$ARGUMENTS`, tabla CA→tests, riesgo, y el veredicto del revisor. Nunca a `main` directo.

## 8. Cierre
Escribe `.fabrica/estado.json` con `"fase": "build"`, `"resultado"` y `"riesgo"`. No lo commitees.

## Reglas de ejecución (obligatorias, en local y en CI)
1. Cada subagente se lanza con la herramienta **Agent en primer plano**: nunca con `run_in_background`, y esperas su resultado antes de seguir.
2. **Cada ronda es un Agent nuevo.** Nunca uses `SendMessage` para continuar un agente anterior. En el prompt de la ronda pasa la ruta del artefacto y los hallazgos del revisor **literales**.
3. El **revisor de cada ronda también es una instancia nueva** (independencia: no revisa con el contexto de la ronda anterior).
4. No uses comandos en segundo plano (`&`, `nohup`) ni esperes eventos externos.
5. **No cierres el turno sin haber escrito `.fabrica/estado.json`.** Es lo último que haces. Si algo falla o no puedes terminar, escríbelo igual con `"resultado": "escalar"` y el motivo.
