#!/usr/bin/env bash
# Instala la fábrica en un VPS Ubuntu/Debian. Ejecutar como root:  sudo bash vps/setup.sh
# Crea el usuario "fabrica", instala Node, Claude Code, gh, tmux, el runner de GitHub y los servicios.
set -euo pipefail
USUARIO=fabrica
HOME_F=/home/$USUARIO

echo "==> Paquetes base"
apt-get update -y
apt-get install -y curl git jq tmux unzip ca-certificates python3 python3-pip pipx

echo "==> Usuario $USUARIO (sin sudo: el agente no debe administrar el servidor)"
id $USUARIO &>/dev/null || useradd -m -s /bin/bash $USUARIO
loginctl enable-linger $USUARIO   # sus servicios systemd --user siguen vivos sin sesión abierta

echo "==> Node 22 + Claude Code"
curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
apt-get install -y nodejs
sudo -iu $USUARIO bash -c 'mkdir -p ~/.npm-global && npm config set prefix ~/.npm-global \
  && grep -q npm-global ~/.bashrc || echo "export PATH=\$HOME/.npm-global/bin:\$PATH" >> ~/.bashrc'
sudo -iu $USUARIO bash -c 'export PATH=$HOME/.npm-global/bin:$PATH && npm i -g @anthropic-ai/claude-code'

echo "==> GitHub CLI"
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg -o /usr/share/keyrings/githubcli.gpg
echo "deb [signed-by=/usr/share/keyrings/githubcli.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list
apt-get update -y && apt-get install -y gh

echo "==> Servicio de sesión remota (Claude en tmux, controlable desde la app móvil)"
install -d -o $USUARIO -g $USUARIO $HOME_F/.config/systemd/user $HOME_F/repos
install -o $USUARIO -g $USUARIO -m 644 "$(dirname "$0")/claude-remoto.service" $HOME_F/.config/systemd/user/
install -o $USUARIO -g $USUARIO -m 755 "$(dirname "$0")/../ops/monitor.sh" $HOME_F/monitor.sh

echo "==> Configuración base de Claude (global, para todas las sesiones)"
install -d -o $USUARIO -g $USUARIO $HOME_F/.claude
[[ -f $HOME_F/.claude/CLAUDE.md ]]     || install -o $USUARIO -g $USUARIO -m 644 "$(dirname "$0")/CLAUDE.global.md" $HOME_F/.claude/CLAUDE.md
[[ -f $HOME_F/.claude/settings.json ]] || install -o $USUARIO -g $USUARIO -m 644 "$(dirname "$0")/settings.global.json" $HOME_F/.claude/settings.json
grep -q TU_USUARIO $HOME_F/.claude/settings.json && echo "⚠️  Edita ~$USUARIO/.claude/settings.json y reemplaza TU_USUARIO por tu usuario de GitHub"

cat <<'MSG'

✅ Base instalada. Pasos manuales (una sola vez), como usuario fabrica:  sudo -iu fabrica

1) Autenticación de Claude (suscripción Pro/Max) y plugin:
     claude            # inicia sesión; /config → "Enable Remote Control for all sessions"
                       # luego, dentro de claude:
                       #   /plugin marketplace add TU_USUARIO/betacode-fabrica
                       #   /plugin install fabrica@betacode       (alcance: usuario)
     claude setup-token  # genera el token largo → guárdalo en GitHub como secret CLAUDE_CODE_OAUTH_TOKEN
2) GitHub:
     gh auth login
     gh auth setup-git     # para que git use las credenciales de gh
3) (Solo cuando quieras el modo CI automático) Runner self-hosted por repo o por organización:
     mkdir ~/actions-runner && cd ~/actions-runner   # pega los comandos que te da GitHub
     ./config.sh --url https://github.com/<usuario>/<repo> --token <TOKEN> --labels fabrica --unattended
     # Con una organización GitHub (gratis) registras UN runner para todos los repos.
     sudo ./svc.sh install fabrica && sudo ./svc.sh start      # (este paso como root)
4) Sesión lobby persistente (si systemctl --user falla con sudo -iu, entra con: machinectl shell fabrica@):
     systemctl --user daemon-reload && systemctl --user enable --now claude-remoto
     → En la app Claude del móvil: Code → aparece la sesión del VPS.
5) Monitor de producción (fase 7):
     crontab -e   →   */5 * * * * REPO=<usuario>/<repo> ~/monitor.sh >> ~/monitor.log 2>&1
MSG
