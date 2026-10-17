#!/usr/bin/env bash
# Pull the RUNNING config of switches into backups/<minion>.cfg (read-only on the devices).
# backups/<minion>.cfg      -> hashes redacted, committed to git (safe to publish)
# backups/raw/<minion>.cfg  -> exact copy for rollback, git-ignored, stays on the master
#   sudo tools/backup.sh                    # every switch in nodegroup 'switches'
#   sudo tools/backup.sh dc3-leaf1 leaf1    # just these
#   sudo tools/backup.sh internet-rtr       # the IOS router works too
set -euo pipefail
cd "$(dirname "$0")/.."
PY=/opt/saltstack/salt/bin/python3
if [ $# -gt 0 ]; then targets="$*"; else
  targets=$(salt -N switches test.ping --out=json --static | $PY -c 'import json,sys; print(" ".join(sorted(k for k,v in json.load(sys.stdin).items() if v is True)))')
fi
mkdir -p backups/raw && chmod 700 backups/raw
for m in $targets; do
  if salt "$m" net.config source=running --out=json --static > "/tmp/$m.json" 2>/dev/null &&
     $PY -c 'import json,sys; d=json.load(open(sys.argv[1]))[sys.argv[2]]; assert d["result"], d.get("comment"); sys.stdout.write(d["out"]["running"])' "/tmp/$m.json" "$m" > "backups/raw/$m.cfg.tmp"; then
    mv "backups/raw/$m.cfg.tmp" "backups/raw/$m.cfg"; chmod 600 "backups/raw/$m.cfg"
    sed -E 's/(secret sha512 )[^ ]+/\1<redacted>/' "backups/raw/$m.cfg" > "backups/$m.cfg"
    echo "OK    $m  ($(wc -l < backups/$m.cfg) lines)"
  else
    rm -f "backups/raw/$m.cfg.tmp"; echo "FAIL  $m  (is the proxy up? salt $m test.ping)"
  fi
  rm -f "/tmp/$m.json"
done
chown -R --reference=. backups     # keep the repo owned by you, not root
