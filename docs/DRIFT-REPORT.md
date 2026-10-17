# Drift report: intended (templates) vs running configs

`+` = Salt will ADD this line · `-` = Salt will REMOVE this line


## spine1  (+30 / -31)

```diff
- interface Ethernet1 > description leaf1
- interface Ethernet2 > description leaf2
- interface Ethernet3 > description leaf3
- interface Ethernet4 > description border-leaf
- interface Ethernet5 > description leaf4
- interface Ethernet6 > description leaf5
- interface Loopback0 > description BGP EVPN (overlay control plane)
- router bgp 65000 > address-family evpn > neighbor 10.0.250.11 activate
- router bgp 65000 > address-family evpn > neighbor 10.0.250.12 activate
- router bgp 65000 > address-family evpn > neighbor 10.0.250.13 activate
- router bgp 65000 > address-family evpn > neighbor 10.0.250.14 activate
- router bgp 65000 > address-family evpn > neighbor 10.0.250.15 activate
- router bgp 65000 > address-family evpn > neighbor 10.0.250.16 activate
- router bgp 65000 > address-family evpn > neighbor 10.0.250.17 activate
- router bgp 65000 > address-family evpn > neighbor 10.0.250.18 activate
- router bgp 65000 > address-family ipv4 > neighbor 10.0.1.1 activate
- router bgp 65000 > address-family ipv4 > neighbor 10.0.1.11 activate
- router bgp 65000 > address-family ipv4 > neighbor 10.0.1.13 activate
- router bgp 65000 > address-family ipv4 > neighbor 10.0.1.15 activate
- router bgp 65000 > address-family ipv4 > neighbor 10.0.1.3 activate
- router bgp 65000 > address-family ipv4 > neighbor 10.0.1.5 activate
- router bgp 65000 > address-family ipv4 > neighbor 10.0.1.7 activate
- router bgp 65000 > address-family ipv4 > neighbor 10.0.1.9 activate
- router bgp 65000 > neighbor 10.0.1.11 remote-as 65003
- router bgp 65000 > neighbor 10.0.1.7 remote-as 65002
- router bgp 65000 > neighbor 10.0.250.14 peer group evpn
- router bgp 65000 > neighbor 10.0.250.14 remote-as 65002
- router bgp 65000 > neighbor 10.0.250.16 peer group evpn
- router bgp 65000 > neighbor 10.0.250.16 remote-as 65003
- username monitor role network-operator secret sha512 <redacted>
- username salt privilege 15 role network-admin secret sha512 <redacted>
+ interface Ethernet1 > description leaf1 Ethernet11
+ interface Ethernet2 > description leaf2 Ethernet11
+ interface Ethernet3 > description leaf3 Ethernet11
+ interface Ethernet4 > description border-leaf Ethernet1
+ interface Ethernet5 > description leaf4 Ethernet11
+ interface Ethernet6 > description leaf5 Ethernet11
+ interface Loopback0 > description EVPN router-id
+ router bgp 65000 > address-family ipv4 > neighbor underlay activate
+ router bgp 65000 > neighbor 10.0.1.1 description leaf1-underlay
+ router bgp 65000 > neighbor 10.0.1.1 peer group underlay
+ router bgp 65000 > neighbor 10.0.1.13 description leaf4-underlay
+ router bgp 65000 > neighbor 10.0.1.13 peer group underlay
+ router bgp 65000 > neighbor 10.0.1.15 description leaf5-underlay
+ router bgp 65000 > neighbor 10.0.1.15 peer group underlay
+ router bgp 65000 > neighbor 10.0.1.3 description leaf2-underlay
+ router bgp 65000 > neighbor 10.0.1.3 peer group underlay
+ router bgp 65000 > neighbor 10.0.1.5 description leaf3-underlay
+ router bgp 65000 > neighbor 10.0.1.5 peer group underlay
+ router bgp 65000 > neighbor 10.0.1.9 description border-leaf-underlay
+ router bgp 65000 > neighbor 10.0.1.9 peer group underlay
+ router bgp 65000 > neighbor 10.0.250.11 description leaf1-EVPN-Lo0
+ router bgp 65000 > neighbor 10.0.250.12 description leaf2-EVPN-Lo0
+ router bgp 65000 > neighbor 10.0.250.13 description leaf3-EVPN-Lo0
+ router bgp 65000 > neighbor 10.0.250.15 description border-leaf-EVPN-Lo0
+ router bgp 65000 > neighbor 10.0.250.17 description leaf4-EVPN-Lo0
+ router bgp 65000 > neighbor 10.0.250.18 description leaf5-EVPN-Lo0
+ router bgp 65000 > neighbor underlay maximum-routes 12000 warning-only
+ router bgp 65000 > neighbor underlay peer group
+ username monitor role network-operator secret sha512 <redacted>
+ username salt privilege 15 role network-admin secret sha512 <redacted>
```

## spine2  (+30 / -31)

```diff
- interface Ethernet1 > description leaf1
- interface Ethernet2 > description leaf2
- interface Ethernet3 > description leaf3
- interface Ethernet4 > description border-leaf
- interface Ethernet5 > description leaf4
- interface Ethernet6 > description leaf5
- router bgp 65000 > address-family evpn > neighbor 10.0.250.11 activate
- router bgp 65000 > address-family evpn > neighbor 10.0.250.12 activate
- router bgp 65000 > address-family evpn > neighbor 10.0.250.13 activate
- router bgp 65000 > address-family evpn > neighbor 10.0.250.14 activate
- router bgp 65000 > address-family evpn > neighbor 10.0.250.15 activate
- router bgp 65000 > address-family evpn > neighbor 10.0.250.16 activate
- router bgp 65000 > address-family evpn > neighbor 10.0.250.17 activate
- router bgp 65000 > address-family evpn > neighbor 10.0.250.18 activate
- router bgp 65000 > address-family ipv4 > neighbor 10.0.2.1 activate
- router bgp 65000 > address-family ipv4 > neighbor 10.0.2.11 activate
- router bgp 65000 > address-family ipv4 > neighbor 10.0.2.13 activate
- router bgp 65000 > address-family ipv4 > neighbor 10.0.2.15 activate
- router bgp 65000 > address-family ipv4 > neighbor 10.0.2.3 activate
- router bgp 65000 > address-family ipv4 > neighbor 10.0.2.5 activate
- router bgp 65000 > address-family ipv4 > neighbor 10.0.2.7 activate
- router bgp 65000 > address-family ipv4 > neighbor 10.0.2.9 activate
- router bgp 65000 > neighbor 10.0.2.11 remote-as 65003
- router bgp 65000 > neighbor 10.0.2.7 remote-as 65002
- router bgp 65000 > neighbor 10.0.250.14 peer group evpn
- router bgp 65000 > neighbor 10.0.250.14 remote-as 65002
- router bgp 65000 > neighbor 10.0.250.16 peer group evpn
- router bgp 65000 > neighbor 10.0.250.16 remote-as 65003
- router bgp 65000 > neighbor evpn route-reflector-client
- username monitor role network-operator secret sha512 <redacted>
- username salt privilege 15 role network-admin secret sha512 <redacted>
+ interface Ethernet1 > description leaf1 Ethernet12
+ interface Ethernet2 > description leaf2 Ethernet12
+ interface Ethernet3 > description leaf3 Ethernet12
+ interface Ethernet4 > description border-leaf Ethernet2
+ interface Ethernet5 > description leaf4 Ethernet12
+ interface Ethernet6 > description leaf5 Ethernet12
+ interface Loopback0 > description EVPN router-id
+ router bgp 65000 > address-family ipv4 > neighbor underlay activate
+ router bgp 65000 > neighbor 10.0.2.1 description leaf1-underlay
+ router bgp 65000 > neighbor 10.0.2.1 peer group underlay
+ router bgp 65000 > neighbor 10.0.2.13 description leaf4-underlay
+ router bgp 65000 > neighbor 10.0.2.13 peer group underlay
+ router bgp 65000 > neighbor 10.0.2.15 description leaf5-underlay
+ router bgp 65000 > neighbor 10.0.2.15 peer group underlay
+ router bgp 65000 > neighbor 10.0.2.3 description leaf2-underlay
+ router bgp 65000 > neighbor 10.0.2.3 peer group underlay
+ router bgp 65000 > neighbor 10.0.2.5 description leaf3-underlay
+ router bgp 65000 > neighbor 10.0.2.5 peer group underlay
+ router bgp 65000 > neighbor 10.0.2.9 description border-leaf-underlay
+ router bgp 65000 > neighbor 10.0.2.9 peer group underlay
+ router bgp 65000 > neighbor 10.0.250.11 description leaf1-EVPN-Lo0
+ router bgp 65000 > neighbor 10.0.250.12 description leaf2-EVPN-Lo0
+ router bgp 65000 > neighbor 10.0.250.13 description leaf3-EVPN-Lo0
+ router bgp 65000 > neighbor 10.0.250.15 description border-leaf-EVPN-Lo0
+ router bgp 65000 > neighbor 10.0.250.17 description leaf4-EVPN-Lo0
+ router bgp 65000 > neighbor 10.0.250.18 description leaf5-EVPN-Lo0
+ router bgp 65000 > neighbor underlay maximum-routes 12000 warning-only
+ router bgp 65000 > neighbor underlay peer group
+ username monitor role network-operator secret sha512 <redacted>
+ username salt privilege 15 role network-admin secret sha512 <redacted>
```

## leaf1  (+17 / -12)

```diff
- interface Ethernet10 > description mlag peer link
- interface Ethernet11 > description spine1
- interface Ethernet12 > description spine2
- interface Port-Channel999 > description MLAG Peer
- router bgp 65001 > address-family evpn > neighbor 10.0.250.1 activate
- router bgp 65001 > address-family evpn > neighbor 10.0.250.2 activate
- router bgp 65001 > neighbor 10.0.250.1 bfd
- router bgp 65001 > neighbor 10.0.250.2 bfd
- router bgp 65001 > vlan 40 > rd 65001:100040
- router bgp 65001 > vrf gold > route-target export 1:100001
- router bgp 65001 > vrf gold > route-target import 1:100001
- vlan 40 > name test-l2-vxlan
+ interface Ethernet1 > description VPC1
+ interface Ethernet10 > description MLAG peer-link to leaf2
+ interface Ethernet11 > description spine1 Ethernet1
+ interface Ethernet12 > description spine2 Ethernet1
+ interface Loopback0 > description EVPN router-id
+ interface Loopback1 > description VTEP
+ interface Port-Channel999 > description MLAG peer-link to leaf2
+ router bgp 65001 > neighbor 10.0.1.0 description spine1-underlay
+ router bgp 65001 > neighbor 10.0.2.0 description spine2-underlay
+ router bgp 65001 > neighbor 10.0.250.1 description spine1-EVPN-Lo0
+ router bgp 65001 > neighbor 10.0.250.2 description spine2-EVPN-Lo0
+ router bgp 65001 > neighbor 10.0.3.1 description leaf2-ibgp
+ router bgp 65001 > neighbor evpn bfd
+ router bgp 65001 > vlan 40 > rd 10.0.250.11:40
+ router bgp 65001 > vrf gold > route-target export evpn 1:100001
+ router bgp 65001 > vrf gold > route-target import evpn 1:100001
+ vlan 40 > name APP-40
```

## leaf2  (+19 / -10)

```diff
- interface Ethernet10 > description mlag peer link
- interface Ethernet11 > description spine1
- interface Ethernet12 > description spine2
- interface Port-Channel999 > description MLAG Peer
- router bgp 65001 > address-family evpn > neighbor 10.0.250.1 activate
- router bgp 65001 > address-family evpn > neighbor 10.0.250.2 activate
- router bgp 65001 > vlan 40 > rd 65001:100041
- username monitor role network-operator secret sha512 <redacted>
- username salt privilege 15 role network-admin secret sha512 <redacted>
- vlan 40 > name test-l2-vxlan
+ interface Ethernet1 > description VPC2
+ interface Ethernet10 > description MLAG peer-link to leaf1
+ interface Ethernet11 > description spine1 Ethernet2
+ interface Ethernet12 > description spine2 Ethernet2
+ interface Loopback0 > description EVPN router-id
+ interface Loopback1 > description VTEP
+ interface Port-Channel999 > description MLAG peer-link to leaf1
+ router bfd
+ router bfd > multihop interval 1000 min-rx 1000 multiplier 3
+ router bgp 65001 > neighbor 10.0.1.2 description spine1-underlay
+ router bgp 65001 > neighbor 10.0.2.2 description spine2-underlay
+ router bgp 65001 > neighbor 10.0.250.1 description spine1-EVPN-Lo0
+ router bgp 65001 > neighbor 10.0.250.2 description spine2-EVPN-Lo0
+ router bgp 65001 > neighbor 10.0.3.0 description leaf1-ibgp
+ router bgp 65001 > neighbor evpn bfd
+ router bgp 65001 > vlan 40 > rd 10.0.250.12:40
+ username monitor role network-operator secret sha512 <redacted>
+ username salt privilege 15 role network-admin secret sha512 <redacted>
+ vlan 40 > name APP-40
```

## leaf3  (+19 / -6)

```diff
- interface Ethernet11 > description spine1
- interface Ethernet12 > description spine2
- username monitor role network-operator secret sha512 <redacted>
- username salt privilege 15 role network-admin secret sha512 <redacted>
- vlan 40 > name test-l2-vxlan
- vlan 50 > name test-l3
+ interface Ethernet1 > description VPC3
+ interface Ethernet11 > description spine1 Ethernet3
+ interface Ethernet12 > description spine2 Ethernet3
+ interface Ethernet2 > description VPC4
+ interface Loopback0 > description EVPN router-id
+ interface Loopback1 > description VTEP
+ router bfd
+ router bfd > multihop interval 1000 min-rx 1000 multiplier 3
+ router bgp 65002 > neighbor 10.0.1.4 description spine1-underlay
+ router bgp 65002 > neighbor 10.0.2.4 description spine2-underlay
+ router bgp 65002 > neighbor 10.0.250.1 description spine1-EVPN-Lo0
+ router bgp 65002 > neighbor 10.0.250.2 description spine2-EVPN-Lo0
+ router bgp 65002 > neighbor evpn bfd
+ router bgp 65002 > neighbor evpn maximum-routes 12000 warning-only
+ router bgp 65002 > neighbor underlay maximum-routes 12000 warning-only
+ username monitor role network-operator secret sha512 <redacted>
+ username salt privilege 15 role network-admin secret sha512 <redacted>
+ vlan 40 > name APP-40
+ vlan 50 > name APP-50
```

## leaf4  (+11 / -8)

```diff
- interface Ethernet11 > description spine1 Eth5
- interface Ethernet12 > description spine2 Eth5
- router bgp 65004 > address-family ipv4 > neighbor 10.0.1.12 activate
- router bgp 65004 > address-family ipv4 > neighbor 10.0.2.12 activate
- router bgp 65004 > neighbor 10.0.1.12 remote-as 65000
- router bgp 65004 > neighbor 10.0.2.12 remote-as 65000
- username monitor role network-operator secret sha512 <redacted>
- username salt privilege 15 role network-admin secret sha512 <redacted>
+ interface Ethernet11 > description spine1 Ethernet5
+ interface Ethernet12 > description spine2 Ethernet5
+ router bgp 65004 > address-family ipv4 > neighbor underlay activate
+ router bgp 65004 > neighbor 10.0.1.12 peer group underlay
+ router bgp 65004 > neighbor 10.0.2.12 peer group underlay
+ router bgp 65004 > neighbor evpn maximum-routes 12000 warning-only
+ router bgp 65004 > neighbor underlay maximum-routes 12000 warning-only
+ router bgp 65004 > neighbor underlay peer group
+ router bgp 65004 > neighbor underlay remote-as 65000
+ username monitor role network-operator secret sha512 <redacted>
+ username salt privilege 15 role network-admin secret sha512 <redacted>
```

## leaf5  (+11 / -8)

```diff
- interface Ethernet11 > description spine1 Eth6
- interface Ethernet12 > description spine2 Eth6
- router bgp 65005 > address-family ipv4 > neighbor 10.0.1.14 activate
- router bgp 65005 > address-family ipv4 > neighbor 10.0.2.14 activate
- router bgp 65005 > neighbor 10.0.1.14 remote-as 65000
- router bgp 65005 > neighbor 10.0.2.14 remote-as 65000
- username monitor role network-operator secret sha512 <redacted>
- username salt privilege 15 role network-admin secret sha512 <redacted>
+ interface Ethernet11 > description spine1 Ethernet6
+ interface Ethernet12 > description spine2 Ethernet6
+ router bgp 65005 > address-family ipv4 > neighbor underlay activate
+ router bgp 65005 > neighbor 10.0.1.14 peer group underlay
+ router bgp 65005 > neighbor 10.0.2.14 peer group underlay
+ router bgp 65005 > neighbor evpn maximum-routes 12000 warning-only
+ router bgp 65005 > neighbor underlay maximum-routes 12000 warning-only
+ router bgp 65005 > neighbor underlay peer group
+ router bgp 65005 > neighbor underlay remote-as 65000
+ username monitor role network-operator secret sha512 <redacted>
+ username salt privilege 15 role network-admin secret sha512 <redacted>
```

## border-leaf  (+16 / -4)

```diff
- interface Ethernet1 > description spine1
- interface Ethernet2 > description spine2
- username monitor role network-operator secret sha512 <redacted>
- username salt privilege 15 role network-admin secret sha512 <redacted>
+ interface Ethernet1 > description spine1 Ethernet4
+ interface Ethernet2 > description spine2 Ethernet4
+ interface Loopback0 > description EVPN router-id
+ interface Loopback1 > description VTEP
+ router bfd
+ router bfd > multihop interval 1000 min-rx 1000 multiplier 3
+ router bgp 65003 > neighbor 10.0.1.8 description spine1-underlay
+ router bgp 65003 > neighbor 10.0.2.8 description spine2-underlay
+ router bgp 65003 > neighbor 10.0.250.1 description spine1-EVPN-Lo0
+ router bgp 65003 > neighbor 10.0.250.2 description spine2-EVPN-Lo0
+ router bgp 65003 > neighbor evpn bfd
+ router bgp 65003 > neighbor evpn maximum-routes 12000 warning-only
+ router bgp 65003 > neighbor underlay maximum-routes 12000 warning-only
+ router bgp 65003 > vrf gold > neighbor 172.16.100.1 description internet-rtr
+ username monitor role network-operator secret sha512 <redacted>
+ username salt privilege 15 role network-admin secret sha512 <redacted>
```
