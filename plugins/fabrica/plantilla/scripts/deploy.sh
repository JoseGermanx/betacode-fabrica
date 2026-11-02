#!/usr/bin/env bash
# Despliegue determinista por rsync/SSH. Adáptalo a cada proyecto (cPanel, VPS, serverless...).
set -euo pipefail
: "${DEPLOY_HOST:?}" "${DEPLOY_USER:?}" "${DEPLOY_KEY:?}" "${DEPLOY_PATH:?}"
key=$(mktemp); trap 'rm -f "$key"' EXIT
printf '%s\n' "$DEPLOY_KEY" > "$key"; chmod 600 "$key"

# Build (si aplica)
[[ -f package.json ]] && npm ci && npm run build --if-present

# Copia atómica: sube a release nueva y cambia el symlink (rollback = apuntar al release anterior)
REL="releases/$(date +%Y%m%d%H%M%S)"
SRC="${BUILD_DIR:-.}/"
ssh -i "$key" -o StrictHostKeyChecking=accept-new "$DEPLOY_USER@$DEPLOY_HOST" "mkdir -p $DEPLOY_PATH/$REL"
rsync -az --delete --exclude '.git' --exclude '.github' --exclude '.claude' --exclude 'docs/specs' \
  -e "ssh -i $key" "$SRC" "$DEPLOY_USER@$DEPLOY_HOST:$DEPLOY_PATH/$REL/"
ssh -i "$key" "$DEPLOY_USER@$DEPLOY_HOST" "cd $DEPLOY_PATH && ln -sfn $REL current && ls -1dt releases/* | tail -n +6 | xargs -r rm -rf"
echo "Desplegado $REL"
