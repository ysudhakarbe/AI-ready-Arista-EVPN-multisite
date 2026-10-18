#!/opt/saltstack/salt/bin/python3 -W ignore::DeprecationWarning
"""Ping from every VPC to every destination through the EVE-NG telnet consoles.

    tools/pingmatrix.py                 # full matrix
    tools/pingmatrix.py VPC1 VPC7       # only these sources

Console ports are random in this EVE-NG version and change when nodes restart, so they are
looked up live from the EVE-NG API on every run. EVE web login is read from ~/.eve.conf
(one line:  admin:password  , chmod 600, never committed).
"""
import json
import os
import re
import ssl
import sys
import urllib.request
from http.cookiejar import CookieJar
import telnetlib            # in the Salt onedir Python; removed from Python 3.13+
import time
from concurrent.futures import ThreadPoolExecutor

EVE = "192.168.1.3"
LAB = "Arista Lab.unl"
VPCS = {                      # name: (console port - refreshed from the EVE API, own IP)
    "VPC1": (38373, "10.40.40.10"),
    "VPC2": (57901, "10.40.40.30"),
    "VPC3": (45833, "10.40.40.20"),
    "VPC4": (40139, "10.50.50.10"),
    "VPC5": (51621, "10.60.60.10"),
    "VPC6": (46721, "10.40.40.60"),
    "VPC7": (47551, "10.70.70.10"),
}


def refresh_ports():
    """Replace the console ports above with the live ones from the EVE-NG API (falls back to the table)."""
    try:
        user, pw = open(os.path.expanduser("~/.eve.conf")).read().strip().split(":", 1)
        ctx = ssl._create_unverified_context()           # EVE uses a self-signed cert
        op = urllib.request.build_opener(urllib.request.ProxyHandler({}),     # never via the HTTP proxy
                                         urllib.request.HTTPSHandler(context=ctx),
                                         urllib.request.HTTPCookieProcessor(CookieJar()))
        body = json.dumps({"username": user, "password": pw, "html5": "-1"}).encode()
        op.open(f"https://{EVE}/api/auth/login", body, timeout=10)
        lab = urllib.request.quote(LAB)
        nodes = json.load(op.open(f"https://{EVE}/api/labs/{lab}/nodes", timeout=10))["data"].values()
        live = {n["name"]: int(n["url"].rsplit(":", 1)[1]) for n in nodes if n.get("url", "").startswith("telnet")}
        for name in VPCS:
            if name in live:
                VPCS[name] = (live[name], VPCS[name][1])
        json.dump({n: p for n, (p, ip) in VPCS.items()}, open(CACHE, "w"))
        return "ports refreshed from EVE API and saved (your EVE web session was logged out)"
    except Exception as e:
        return f"EVE API not used ({e.__class__.__name__}); using ports in the script"


CACHE = os.path.expanduser("~/.eve-ports.json")


def load_cache():
    try:
        for n, p in json.load(open(CACHE)).items():
            if n in VPCS:
                VPCS[n] = (p, VPCS[n][1])
        return "ports from cache (~/.eve-ports.json)"
    except Exception:
        return "no port cache yet; using ports in the script (run with --refresh once)"


EXTRA = {"SRV-1": "10.40.40.70", "inet-rtr": "172.16.100.1", "8.8.8.8": "8.8.8.8"}
PROMPT = re.compile(rb"\S+> ?$", re.M)


def run(name):
    port, me = VPCS[name]
    results = {}
    try:
        tn = telnetlib.Telnet(EVE, port, timeout=10)
        tn.write(b"\r\n")
        time.sleep(1)
        tn.read_very_eager()                       # flush banner and stray prompts
        targets = {n: ip for n, (p, ip) in VPCS.items() if n != name} | EXTRA
        tn.write(b"show ip\r\n"); time.sleep(1); tn.read_very_eager()   # warm-up command
        for dst, ip in targets.items():
            ok = 0
            for attempt in (1, 2):                 # retry once (session start / ARP)
                cmd = f"ping {ip} -c 2"
                tn.write(cmd.encode() + b"\r\n")
                tn.read_until(cmd.encode(), timeout=5)  # anchor on the echoed command
                _, _, out = tn.expect([PROMPT], timeout=15)
                ok = len(re.findall(r"bytes from|icmp_seq=\d+ ttl", out.decode(errors="ignore")))
                if ok:
                    break
            results[dst] = "OK" if ok >= 2 else ("~1/2" if ok == 1 else "FAIL")
        tn.close()
    except Exception as e:                       # console busy / wrong port
        results["_error"] = str(e)
    return name, results


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    srcs = args or list(VPCS)
    t0 = time.time()
    print(refresh_ports() if "--refresh" in sys.argv else load_cache())
    with ThreadPoolExecutor(max_workers=len(srcs)) as ex:
        res = dict(ex.map(run, srcs))
    cols = list(VPCS) + list(EXTRA)
    hdr = "src/dst"
    print(f"{hdr:10}" + "".join(f"{c:>9}" for c in cols))
    fails = 0
    for s in srcs:
        r = res[s]
        if "_error" in r:
            print(f"{s:10}  console error: {r['_error']}  -> ports changed? run: pingmatrix --refresh")
            fails += 1
            continue
        row = []
        for c in cols:
            v = "-" if c == s else r.get(c, "?")
            fails += v not in ("OK", "-")
            row.append(f"{v:>9}")
        print(f"{s:10}" + "".join(row))
    print(f"\n{'ALL OK' if not fails else f'{fails} problem(s)'}  ({time.time() - t0:.0f}s)")
    return 1 if fails else 0


if __name__ == "__main__":
    sys.exit(main())
