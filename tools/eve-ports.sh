#!/usr/bin/env bash
# List EVE-NG console ports:  tools/eve-ports.sh <eve-ip> "<lab path, e.g. Arista/EVPN.unl>"
EVE=$1; LAB=$2
read -rp "EVE user [admin]: " U; U=${U:-admin}; read -rsp "EVE password: " P; echo
C=$(mktemp)
curl -sk --noproxy "*" -c "$C" -X POST -d "{\"username\":\"$U\",\"password\":\"$P\",\"html5\":\"-1\"}" "https://$EVE/api/auth/login" >/dev/null
curl -sk --noproxy "*" -b "$C" "https://$EVE/api/labs/${LAB// /%20}/nodes" | /opt/saltstack/salt/bin/python3 -c '
import json, sys
d = json.load(sys.stdin)
if "data" not in d: sys.exit(f"EVE says: {d}")
for n in sorted(d["data"].values(), key=lambda n: n["name"]):
    print(n["name"].ljust(20), n.get("url", ""))'
rm -f "$C"
