# Drift report: intended (templates) vs running configs

`+` = Salt will ADD this line · `-` = Salt will REMOVE this line


## spine1  (+3 / -3)

```diff
- interface Ethernet4 > description border-leaf Ethernet1
- router bgp 65000 > neighbor 10.0.1.9 description border-leaf-underlay
- router bgp 65000 > neighbor 10.0.250.15 description border-leaf-EVPN-Lo0
+ interface Ethernet4 > description dc1-border-leaf Ethernet1
+ router bgp 65000 > neighbor 10.0.1.9 description dc1-border-leaf-underlay
+ router bgp 65000 > neighbor 10.0.250.15 description dc1-border-leaf-EVPN-Lo0
```

## spine2  (+3 / -3)

```diff
- interface Ethernet4 > description border-leaf Ethernet2
- router bgp 65000 > neighbor 10.0.2.9 description border-leaf-underlay
- router bgp 65000 > neighbor 10.0.250.15 description border-leaf-EVPN-Lo0
+ interface Ethernet4 > description dc1-border-leaf Ethernet2
+ router bgp 65000 > neighbor 10.0.2.9 description dc1-border-leaf-underlay
+ router bgp 65000 > neighbor 10.0.250.15 description dc1-border-leaf-EVPN-Lo0
```

## leaf1  (+0 / -0)

```diff
```

## leaf2  (+0 / -0)

```diff
```

## leaf3  (+0 / -0)

```diff
```

## leaf4  (+0 / -0)

```diff
```

## leaf5  (+0 / -0)

```diff
```

## dc1-border-leaf  (+0 / -0)

```diff
```

## dc2-border-leaf  (+22 / -8)

```diff
- interface Ethernet1 > description dc2-leaf1
- router bgp 65200 > address-family evpn > neighbor 10.1.250.11 activate
- router bgp 65200 > address-family ipv4 > neighbor 10.1.1.1 activate
- router bgp 65200 > neighbor 10.1.250.11 ebgp-multihop 3
- router bgp 65200 > neighbor 10.1.250.11 send-community extended
- router bgp 65200 > neighbor 10.1.250.11 update-source Loopback0
- username monitor role network-operator secret sha512 <redacted>
- username salt privilege 15 role network-admin secret sha512 <redacted>
+ interface Ethernet1 > description dc2-leaf1 Ethernet11
+ interface Loopback0 > description EVPN router-id
+ interface Loopback1 > description VTEP
+ router bfd
+ router bfd > multihop interval 1000 min-rx 1000 multiplier 3
+ router bgp 65200 > address-family evpn > neighbor evpn activate
+ router bgp 65200 > address-family ipv4 > neighbor underlay activate
+ router bgp 65200 > neighbor 10.1.1.1 description dc2-leaf1-underlay
+ router bgp 65200 > neighbor 10.1.1.1 peer group underlay
+ router bgp 65200 > neighbor 10.1.250.11 description dc2-leaf1-EVPN-Lo0
+ router bgp 65200 > neighbor 10.1.250.11 peer group evpn
+ router bgp 65200 > neighbor evpn bfd
+ router bgp 65200 > neighbor evpn ebgp-multihop 3
+ router bgp 65200 > neighbor evpn maximum-routes 12000 warning-only
+ router bgp 65200 > neighbor evpn peer group
+ router bgp 65200 > neighbor evpn send-community extended
+ router bgp 65200 > neighbor evpn update-source Loopback0
+ router bgp 65200 > neighbor underlay maximum-routes 12000 warning-only
+ router bgp 65200 > neighbor underlay peer group
+ router bgp 65200 > vrf gold > neighbor 172.16.200.0 description DC1-BL-gold
+ username monitor role network-operator secret sha512 <redacted>
+ username salt privilege 15 role network-admin secret sha512 <redacted>
```

## dc2-leaf1  (+30 / -11)

```diff
- interface Ethernet11 > description dc2-border-leaf
- router bgp 65201 > address-family evpn > neighbor 10.1.250.15 activate
- router bgp 65201 > address-family ipv4 > neighbor 10.1.1.0 activate
- router bgp 65201 > neighbor 10.1.1.0 remote-as 65200
- router bgp 65201 > neighbor 10.1.250.15 ebgp-multihop 3
- router bgp 65201 > neighbor 10.1.250.15 remote-as 65200
- router bgp 65201 > neighbor 10.1.250.15 send-community extended
- router bgp 65201 > neighbor 10.1.250.15 update-source Loopback0
- username monitor role network-operator secret sha512 <redacted>
- username salt privilege 15 role network-admin secret sha512 <redacted>
- vlan 60 > name dc2-app
+ interface Ethernet1 > description DC2-host
+ interface Ethernet11 > description dc2-border-leaf Ethernet1
+ interface Loopback0 > description EVPN router-id
+ interface Loopback1 > description VTEP
+ interface Vxlan1 > vxlan vlan 60 vni 110060
+ router bfd
+ router bfd > multihop interval 1000 min-rx 1000 multiplier 3
+ router bgp 65201 > address-family evpn > neighbor evpn activate
+ router bgp 65201 > address-family ipv4 > neighbor underlay activate
+ router bgp 65201 > neighbor 10.1.1.0 description dc2-border-leaf-underlay
+ router bgp 65201 > neighbor 10.1.1.0 peer group underlay
+ router bgp 65201 > neighbor 10.1.250.15 description dc2-border-leaf-EVPN-Lo0
+ router bgp 65201 > neighbor 10.1.250.15 peer group evpn
+ router bgp 65201 > neighbor evpn bfd
+ router bgp 65201 > neighbor evpn ebgp-multihop 3
+ router bgp 65201 > neighbor evpn maximum-routes 12000 warning-only
+ router bgp 65201 > neighbor evpn peer group
+ router bgp 65201 > neighbor evpn remote-as 65200
+ router bgp 65201 > neighbor evpn send-community extended
+ router bgp 65201 > neighbor evpn update-source Loopback0
+ router bgp 65201 > neighbor underlay maximum-routes 12000 warning-only
+ router bgp 65201 > neighbor underlay peer group
+ router bgp 65201 > neighbor underlay remote-as 65200
+ router bgp 65201 > vlan 60
+ router bgp 65201 > vlan 60 > rd 10.1.250.11:60
+ router bgp 65201 > vlan 60 > redistribute learned
+ router bgp 65201 > vlan 60 > route-target both 60:110060
+ username monitor role network-operator secret sha512 <redacted>
+ username salt privilege 15 role network-admin secret sha512 <redacted>
+ vlan 60 > name APP-60
```

## dc3-border-leaf  (+16 / -8)

```diff
- router bgp 65300 > address-family evpn > neighbor 10.3.250.11 activate
- router bgp 65300 > address-family ipv4 > neighbor 10.3.1.1 activate
- router bgp 65300 > neighbor 10.3.250.11 description dc3-leaf1-EVPN
- router bgp 65300 > neighbor 10.3.250.11 ebgp-multihop 3
- router bgp 65300 > neighbor 10.3.250.11 send-community extended
- router bgp 65300 > neighbor 10.3.250.11 update-source Loopback0
- username monitor role network-operator secret sha512 <redacted>
- username salt privilege 15 role network-admin secret sha512 <redacted>
+ ip name-server vrf MGMT 8.8.8.8
+ router bgp 65300 > address-family evpn > neighbor evpn activate
+ router bgp 65300 > address-family ipv4 > neighbor underlay activate
+ router bgp 65300 > neighbor 10.3.1.1 peer group underlay
+ router bgp 65300 > neighbor 10.3.250.11 description dc3-leaf1-EVPN-Lo0
+ router bgp 65300 > neighbor 10.3.250.11 peer group evpn
+ router bgp 65300 > neighbor evpn bfd
+ router bgp 65300 > neighbor evpn ebgp-multihop 3
+ router bgp 65300 > neighbor evpn maximum-routes 12000 warning-only
+ router bgp 65300 > neighbor evpn peer group
+ router bgp 65300 > neighbor evpn send-community extended
+ router bgp 65300 > neighbor evpn update-source Loopback0
+ router bgp 65300 > neighbor underlay maximum-routes 12000 warning-only
+ router bgp 65300 > neighbor underlay peer group
+ username monitor role network-operator secret sha512 <redacted>
+ username salt privilege 15 role network-admin secret sha512 <redacted>
```

## dc3-leaf1  (+19 / -11)

```diff
- router bgp 65301 > address-family evpn > neighbor 10.3.250.15 activate
- router bgp 65301 > address-family ipv4 > neighbor 10.3.1.0 activate
- router bgp 65301 > neighbor 10.3.1.0 remote-as 65300
- router bgp 65301 > neighbor 10.3.250.15 description dc3-border-leaf-EVPN
- router bgp 65301 > neighbor 10.3.250.15 ebgp-multihop 3
- router bgp 65301 > neighbor 10.3.250.15 remote-as 65300
- router bgp 65301 > neighbor 10.3.250.15 send-community extended
- router bgp 65301 > neighbor 10.3.250.15 update-source Loopback0
- username monitor role network-operator secret sha512 <redacted>
- username salt privilege 15 role network-admin secret sha512 <redacted>
- vlan 70 > name dc3-app
+ ip name-server vrf MGMT 8.8.8.8
+ router bgp 65301 > address-family evpn > neighbor evpn activate
+ router bgp 65301 > address-family ipv4 > neighbor underlay activate
+ router bgp 65301 > neighbor 10.3.1.0 peer group underlay
+ router bgp 65301 > neighbor 10.3.250.15 description dc3-border-leaf-EVPN-Lo0
+ router bgp 65301 > neighbor 10.3.250.15 peer group evpn
+ router bgp 65301 > neighbor evpn bfd
+ router bgp 65301 > neighbor evpn ebgp-multihop 3
+ router bgp 65301 > neighbor evpn maximum-routes 12000 warning-only
+ router bgp 65301 > neighbor evpn peer group
+ router bgp 65301 > neighbor evpn remote-as 65300
+ router bgp 65301 > neighbor evpn send-community extended
+ router bgp 65301 > neighbor evpn update-source Loopback0
+ router bgp 65301 > neighbor underlay maximum-routes 12000 warning-only
+ router bgp 65301 > neighbor underlay peer group
+ router bgp 65301 > neighbor underlay remote-as 65300
+ username monitor role network-operator secret sha512 <redacted>
+ username salt privilege 15 role network-admin secret sha512 <redacted>
+ vlan 70 > name APP-70
```
