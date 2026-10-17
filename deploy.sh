#!/usr/bin/env bash
# Publish this repo to the Salt master's file roots (/srv/salt, /srv/pillar).
# Run from the repo directory:  sudo ./deploy.sh
set -euo pipefail
cd "$(dirname "$0")"

# 1. never publish a broken template: render + glue-check every device first
/opt/saltstack/salt/bin/python3 tools/render.py >/dev/null
echo "templates render OK"

# 2. copy states and pillar (keep the live credentials file that is not in git)
mkdir -p /srv/salt /srv/pillar/devices
rsync -a --delete salt/ /srv/salt/
[ -f pillar/users.sls ] || { echo "MISSING pillar/users.sls (see pillar/users.sls.example)"; exit 1; }
rsync -a --delete --exclude '_creds.yaml' pillar/ /srv/pillar/
[ -f /srv/pillar/devices/_creds.yaml ] || { echo "MISSING /srv/pillar/devices/_creds.yaml (see _creds.yaml.example)"; exit 1; }

# 3. the salt-master runs as user 'salt'
chown -R salt:salt /srv/salt /srv/pillar
find /srv/pillar -type d -exec chmod 750 {} \;
find /srv/pillar -type f -exec chmod 640 {} \;

# 4. tell every minion about the new data
salt -N all saltutil.refresh_pillar >/dev/null || true
echo "deployed $(git rev-parse --short HEAD 2>/dev/null || echo '(no git)') to /srv - pillar refreshed"
