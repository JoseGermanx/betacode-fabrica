# Instrucciones globales — VPS de la fábrica (Betacode)
<!-- Se instala en ~/.claude/CLAUDE.md del usuario fabrica. Aplica a TODAS las sesiones. -->

- Los proyectos viven en `~/repos/<nombre>`. Esta sesión base ("lobby") arranca en `~/repos`.
- Cuando te pida clonar, crear, retomar o "meter a la fábrica" un proyecto, usa **`/fabrica:init`**. No clones ni instales a mano.
- Las fases (`/fabrica:requisitos N`, etc.) se ejecutan en la **sesión dedicada del proyecto** (ventana tmux con su nombre), no en el lobby. Si te las pido aquí, recuérdamelo o hazlo con `git -C` y rutas absolutas.
- Repos nuevos: siempre privados en GitHub salvo que diga lo contrario.
- Responde en español y en corto: me suelo conectar desde el móvil.
