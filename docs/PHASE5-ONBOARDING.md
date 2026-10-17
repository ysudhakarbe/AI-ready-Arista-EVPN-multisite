# Phase 5: bring every device in the lab under Salt

Goal: all 11 Arista switches (DC1 + DC2 + DC3) are rendered from `pillar/fabric.sls` and applied with
`state.apply fabric`, exactly like the 8 DC1 switches since Phase 4. internet-rtr (Cisco IOSv) joins as a
managed NAPALM device (backups, show commands, drift checks), outside the EVPN template.

> **Golden rule for this phase: nothing is applied until `render.py` and `test=True` agree with what you expect.**
> Until Step 6, every command here is read-only on the switches.

| Device | Minion ID | Mgmt IP | Status before Phase 5 |
|---|---|---|---|
| DC1 spines, leaf1-5 | unchanged | .211-.225 | Salt-managed, zero drift |
| dc1-border-leaf | **renamed** from `border-leaf` | .226 | Salt base + hand-built DCI (EOS 4.36) |
| dc2-border-leaf | dc2-border-leaf | **.230** (was DHCP) | hand-built |
| dc2-leaf1 | dc2-leaf1 | **.231** (was DHCP) | hand-built |
| dc3-border-leaf | dc3-border-leaf | .228 | hand-built (EOS 4.36) |
| dc3-leaf1 | dc3-leaf1 | .229 | hand-built |
| internet-rtr | internet-rtr | **.232** | no SSH yet |

---

## Step 0: safety net (Salt server)

```bash
cd ~/fabric/salt-fabric
git status                         # must be clean
git tag phase5-start
sudo tar czf ~/salt-backup-phase5-start.tgz /srv/salt /srv/pillar /etc/salt/master.d ~/fabric/salt-fabric
```

## Step 1: device prep (EVE console, not SSH)

### DC2 switches: DHCP -> static management (VRF MGMT, eAPI and users already exist)
Check the IPs are free first: `ping -c2 192.168.1.233; ping -c2 192.168.1.231` (no reply = free).

```
configure session mgmt-static
interface Management1
   no dhcp client accept default-route
   ip address 192.168.1.233/24          ! .231 on dc2-leaf1
ip route vrf MGMT 0.0.0.0/0 192.168.1.254
commit
write memory
```
Do it from the EVE console: the address you're connected on changes. The template renders exactly these
lines, so this step only makes the first Salt apply not cut its own session.
If `<salt-password>` was not the password used when the DC2 users were created, also set
`username salt privilege 15 role network-admin secret <salt-password>` here (the proxy logs in with it).

### DC3 switches
Already static (.228/.229) with eAPI and users. Nothing to do.

### Check eAPI from the Salt server (all 5 Arista boxes)
```bash
for ip in 226 228 229 230 231; do
  printf "192.168.1.$ip  "
  curl -sk -u 'salt:<salt-password>' https://192.168.1.$ip/command-api \
    -d '{"jsonrpc":"2.0","method":"runCmds","params":{"version":1,"cmds":["show hostname"]},"id":1}' \
    | grep -o '"hostname": "[^"]*"' || echo "NO eAPI"
done
```

## Step 2: publish the new repo version

```bash
cd ~/fabric/salt-fabric
git am ~/0001-phase5-onboard-dc2-dc3.patch        # or unzip the repo zip over it (see below)
/opt/saltstack/salt/bin/python3 tools/render.py   # all 12 render, no glue/whitespace errors
sudo ./deploy.sh
sudo cp master.d/nodegroups.conf /etc/salt/master.d/nodegroups.conf
sudo systemctl restart salt-master                 # proxies reconnect on their own (Restart=always)
```

## Step 3: start the proxy minions

```bash
# rename border-leaf -> dc1-border-leaf (the switch hostname already is dc1-border-leaf)
sudo systemctl disable --now salt-proxy@border-leaf
sudo salt-key -d border-leaf -y

for m in dc1-border-leaf dc2-border-leaf dc2-leaf1 dc3-border-leaf dc3-leaf1; do
  sudo systemctl enable --now salt-proxy@$m
done
sleep 45                                  # the drop-in waits 20 s before each proxy starts
sudo salt-key -L                          # the 5 new IDs are under "Unaccepted Keys"
sudo salt-key -a 'dc*' -y
sleep 15
sudo salt -N switches test.ping           # 11 x True
sudo salt -N switches grains.get model    # vEOS-lab everywhere
sudo salt -N dc3 net.cli "show version | include Software"
```
The systemd drop-in from Phase 4 (`salt-proxy@.service.d/override.conf`) applies to every
`salt-proxy@<id>` unit, so the new proxies survive a reboot too.

## Step 4: back up what is running today

```bash
cd ~/fabric/salt-fabric
sudo tools/backup.sh                      # backups/<minion>.cfg for all 11
git add backups && git commit -m "Running configs before Phase 5 apply"
```

## Step 5: offline diff (no switch touched)

```bash
/opt/saltstack/salt/bin/python3 tools/render.py --report docs/DRIFT-REPORT-PHASE5.md
```

What you should see, and what it means:

| Device | Expected | Why |
|---|---|---|
| leaf1-5 | `+0 -0` | unchanged since Phase 4 |
| spine1/2 | `+3 -3` | descriptions `border-leaf ...` become `dc1-border-leaf ...` |
| dc1-border-leaf | a few lines | the hand-built DCI is now in the template; expect only cosmetic lines such as `description dc3-border-leaf-EVPN-GW` |
| dc3-border-leaf, dc3-leaf1 | some | hand-built configs normalised to the standard (peer groups, names, descriptions, BFD) |
| dc2-border-leaf | +24 -10 (checked against your configs) | peer groups, BFD, descriptions, DHCP→static, user hashes. Routing data unchanged |
| dc2-leaf1 | +32 -13 (checked) | same + VLAN 60 gets the standard L2VNI 110060 / MAC-VRF and name `APP-60` (was `dc2-app`) |

How to read it: every `-` line exists on the switch and **will be deleted**. For each one, either it's
legacy you want gone (fine), or the pillar is missing data (fix the pillar and re-run). Repeat until every
`-` line is something you mean to remove. Typical fixes: a different IP/ASN in DC2, a VLAN name, a missing
access port.

## Step 6: preview on the switch (EOS computes the diff, nothing changes)

```bash
sudo salt dc3-leaf1 state.apply fabric test=True
```
Compare with the drift report: they must tell the same story.

## Step 7: apply, one switch at a time, lowest risk first

The first apply on a hand-built switch can reset its BGP sessions for a few seconds (neighbors move into
peer groups). Do it as a change window.

| # | Device | Verify after apply |
|---|---|---|
| 1 | dc3-leaf1 | `salt dc3-leaf1 net.cli "show bgp evpn summary"`; VPC6 → `ping 10.40.40.10` (VPC1), VPC7 → `ping 8.8.8.8` |
| 2 | dc3-border-leaf | `net.cli "show bgp evpn summary" "show bgp summary"`: the GW session to 10.0.250.15 is Established; `ping vrf gold 10.3.100.1` |
| 3 | dc1-border-leaf | same + leaf1: `show vxlan address-table vlan 40` still shows VPC6's MAC behind 10.0.255.15 |
| 4 | spine1, then spine2 | description-only change |
| 5 | dc2-leaf1 | `show bgp evpn summary`; host in VLAN 60 pings its gateway |
| 6 | dc2-border-leaf | VRF-lite session to 172.16.200.0 Established; DC2 → DC3 ping (transit via DC1) |

```bash
sudo salt dc3-leaf1 state.apply fabric          # then the checks above, then the next device
```
If a commit breaks something: `sudo salt <dev> net.load_config filename=/home/sudhakar/fabric/salt-fabric/backups/raw/<dev>.cfg replace=True`
puts the Step 4 config back, atomically.

## Step 8: prove zero drift and close the phase

```bash
sudo salt -N switches state.apply fabric test=True --state-output=changes   # "Configuration already applied!" x 11
sudo tools/backup.sh && git add -A && git commit -m "Phase 5: all 11 switches Salt-managed"
git tag phase5-complete
sudo tar czf ~/salt-backup-phase5.tgz /srv/salt /srv/pillar /etc/salt/master.d ~/fabric/salt-fabric
```

The acceptance tests from the DC3 project must all pass again (L2 stretch, L3 both ways, DC2 ↔ DC3, internet).

---

## Optional: internet-rtr (Cisco IOSv) via NAPALM `ios`

1. On the router console (Gi0/1 is the home-LAN/NAT-outside side):
```
conf t
 hostname internet-rtr
 ip domain-name lab.local
 crypto key generate rsa modulus 2048
 ip ssh version 2
 username salt privilege 15 secret <salt-password>
 username monitor privilege 1 secret <monitor-password>
 ip scp server enable                  ! NAPALM copies candidate configs with SCP
 archive
  path flash:archive
  write-memory
 line vty 0 4
  login local
  transport input ssh
 interface GigabitEthernet0/1
  ip address 192.168.1.232 255.255.255.0     ! was DHCP; or reserve the DHCP lease instead
 ip route 0.0.0.0 0.0.0.0 192.168.1.254
end
write memory
```
Check that NAT still works afterwards (VPC7 → `ping 8.8.8.8`): `ip nat inside source ... interface Gi0/1 overload` follows the new IP automatically.

2. Salt server:
```bash
sudo /opt/saltstack/salt/bin/salt-pip list | grep -i -E "napalm|netmiko"   # netmiko needed by the ios driver
sudo systemctl enable --now salt-proxy@internet-rtr
sleep 40; sudo salt-key -a internet-rtr -y
sudo salt internet-rtr test.ping
sudo salt internet-rtr net.cli "show ip bgp summary" "show ip nat translations"
sudo tools/backup.sh internet-rtr
```
3. Make changes without a template (preview first):
```bash
sudo salt internet-rtr net.load_config text='ip ssh time-out 60' test=True
sudo salt internet-rtr net.load_config text='ip ssh time-out 60'
```
It stays out of the `fabric` state (it's in nodegroup `routers`, not `switches`). A full IOS template with
`replace: True` can come later, built from `backups/internet-rtr.cfg` the same way the switches were.
