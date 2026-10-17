# =============================================================================
#  FABRIC SOURCE OF TRUTH  -  Arista EVPN-VXLAN lab, 3 data centers (EVE-NG)
#    DC1 = spine/leaf fabric (vEOS 4.31.2F, border leaf 4.36.3M)
#    DC2 = L3-only DR site, VRF-lite to DC1         (dc2-*)
#    DC3 = metro twin, EVPN gateway to DC1 (4.36)   (dc3-*)
#  Every switch config is rendered from this file. Change the data here,
#  never the switch:  edit -> git commit -> state.apply test=True -> apply.
# =============================================================================
fabric:

  # ---------------------------------------------------------------- global
  global:
    mgmt:
      vrf: MGMT
      gateway: 192.168.1.254
      prefixlen: 24
      dns: [1.1.1.1, 8.8.8.8]
    # users: password hashes live in pillar/users.sls (NOT in git; see users.sls.example).
    #        Salt merges it into fabric.global.users at render time.
    spine_asn: 65000
    anycast_mac: "00:1c:73:00:00:99"
    bfd: {interval: 1000, min_rx: 1000, multiplier: 3}
    max_routes: 12000
    vxlan_port: 4789

    # L2 VNIs (one per VLAN) - name, VNI and anycast gateway are the SAME on every leaf
    vlans:
      - {id: 40, name: APP-40, vni: 110040, gateway: 10.40.40.1/24, vrf: gold}
      - {id: 50, name: APP-50, vni: 110050, gateway: 10.50.50.1/24, vrf: gold}
      - {id: 60, name: APP-60, vni: 110060, gateway: 10.60.60.1/24, vrf: gold}   # DC2 only
      - {id: 70, name: APP-70, vni: 110070, gateway: 10.70.70.1/24, vrf: gold}   # DC3 only

    # L3 VNIs (one per VRF)
    vrfs:
      gold: {l3vni: 100001, rt: "1:100001"}

  # --------------------------------------------------------------- devices
  devices:

    spine1:
      role: spine
      mgmt_ip: 192.168.1.211
      lo0: 10.0.250.1
      # unexplained address found on the running config - kept until you decide
      extra_interfaces:
        - {name: Ethernet12, ip: 10.0.0.140/24}

    spine2:
      role: spine
      mgmt_ip: 192.168.1.212
      lo0: 10.0.250.2
      extra_interfaces:
        - {name: Ethernet12, ip: 10.0.0.141/24}

    leaf1:
      role: leaf
      asn: 65001
      mgmt_ip: 192.168.1.221
      lo0: 10.0.250.11
      vtep: 10.0.255.11            # shared with leaf2 (MLAG)
      uplinks:
        - {peer: spine1, intf: Ethernet11, peer_intf: Ethernet1, ip: 10.0.1.1/31, peer_ip: 10.0.1.0}
        - {peer: spine2, intf: Ethernet12, peer_intf: Ethernet1, ip: 10.0.2.1/31, peer_ip: 10.0.2.0}
      vlans: [40]
      access_ports:
        - {intf: Ethernet1, vlan: 40, description: VPC1}
      mlag:
        peer: leaf2
        domain: leafs
        peer_link_members: [Ethernet10]
        peer_vlan_ip: 10.0.199.254/31
        peer_address: 10.0.199.255
        ibgp_ip: 10.0.3.0/31
        ibgp_peer: 10.0.3.1

    leaf2:
      role: leaf
      asn: 65001
      mgmt_ip: 192.168.1.222
      lo0: 10.0.250.12
      vtep: 10.0.255.11
      uplinks:
        - {peer: spine1, intf: Ethernet11, peer_intf: Ethernet2, ip: 10.0.1.3/31, peer_ip: 10.0.1.2}
        - {peer: spine2, intf: Ethernet12, peer_intf: Ethernet2, ip: 10.0.2.3/31, peer_ip: 10.0.2.2}
      vlans: [40]
      access_ports:
        - {intf: Ethernet1, vlan: 40, description: VPC2}
      mlag:
        peer: leaf1
        domain: leafs
        peer_link_members: [Ethernet10]
        peer_vlan_ip: 10.0.199.255/31
        peer_address: 10.0.199.254
        ibgp_ip: 10.0.3.1/31
        ibgp_peer: 10.0.3.0

    leaf3:
      role: leaf
      asn: 65002
      mgmt_ip: 192.168.1.223
      lo0: 10.0.250.13
      vtep: 10.0.255.13
      uplinks:
        - {peer: spine1, intf: Ethernet11, peer_intf: Ethernet3, ip: 10.0.1.5/31, peer_ip: 10.0.1.4}
        - {peer: spine2, intf: Ethernet12, peer_intf: Ethernet3, ip: 10.0.2.5/31, peer_ip: 10.0.2.4}
      vlans: [40, 50]
      access_ports:
        - {intf: Ethernet1, vlan: 40, description: VPC3}
        - {intf: Ethernet2, vlan: 50, description: VPC4}

    leaf4:
      role: leaf
      asn: 65004
      mgmt_ip: 192.168.1.224
      lo0: 10.0.250.17
      vtep: 10.0.255.17
      uplinks:
        - {peer: spine1, intf: Ethernet11, peer_intf: Ethernet5, ip: 10.0.1.13/31, peer_ip: 10.0.1.12}
        - {peer: spine2, intf: Ethernet12, peer_intf: Ethernet5, ip: 10.0.2.13/31, peer_ip: 10.0.2.12}
      vlans: [40, 50]
      esi_lags:
        - {po: 10, vlan: 40, description: SRV-1 bond0, esi: "0000:0000:0000:0000:0010", rt: "00:00:00:00:00:10", lacp_sysid: 0000.0000.0010,
           members: [{intf: Ethernet1, description: SRV-1 eth0}]}
        - {po: 20, vlan: 50, description: SRV-2 bond0, esi: "0000:0000:0000:0000:0020", rt: "00:00:00:00:00:20", lacp_sysid: 0000.0000.0020,
           members: [{intf: Ethernet2, description: SRV-2 eth0}]}

    leaf5:
      role: leaf
      asn: 65005
      mgmt_ip: 192.168.1.225
      lo0: 10.0.250.18
      vtep: 10.0.255.18
      uplinks:
        - {peer: spine1, intf: Ethernet11, peer_intf: Ethernet6, ip: 10.0.1.15/31, peer_ip: 10.0.1.14}
        - {peer: spine2, intf: Ethernet12, peer_intf: Ethernet6, ip: 10.0.2.15/31, peer_ip: 10.0.2.14}
      vlans: [40, 50]
      esi_lags:
        - {po: 10, vlan: 40, description: SRV-1 bond0, esi: "0000:0000:0000:0000:0010", rt: "00:00:00:00:00:10", lacp_sysid: 0000.0000.0010,
           members: [{intf: Ethernet1, description: SRV-1 eth1}]}
        - {po: 20, vlan: 50, description: SRV-2 bond0, esi: "0000:0000:0000:0000:0020", rt: "00:00:00:00:00:20", lacp_sysid: 0000.0000.0020,
           members: [{intf: Ethernet2, description: SRV-2 eth1}]}

    # ==================================================================== DC1 border
    # hostname on the switch is dc1-border-leaf -> minion ID and pillar key match it
    dc1-border-leaf:
      role: border
      eos_train: "4.36"        # 4.36 shows different default lines (see _header.j2)
      asn: 65003
      mgmt_ip: 192.168.1.226
      lo0: 10.0.250.15
      vtep: 10.0.255.15
      uplinks:
        - {peer: spine1, intf: Ethernet1, peer_intf: Ethernet4, ip: 10.0.1.9/31, peer_ip: 10.0.1.8}
        - {peer: spine2, intf: Ethernet2, peer_intf: Ethernet4, ip: 10.0.2.9/31, peer_ip: 10.0.2.8}
      vlans: []
      external_interfaces:
        - {name: Ethernet3, description: internet-router, vrf: gold, ip: 172.16.100.0/31}
        - {name: Ethernet4, description: DCI-to-DC2, mtu: 9214}
        - {name: Ethernet4.100, encapsulation: 100, vrf: gold, ip: 172.16.200.0/31}
      prefix_lists:
        DCI-OUT:
          - {seq: 10, action: permit, prefix: 0.0.0.0/0}
          - {seq: 20, action: permit, prefix: 10.0.0.0/8 le 24}
      route_maps:
        DCI-OUT:
          - {seq: 10, action: permit, match_prefix_list: DCI-OUT}
      vrf_neighbors:
        gold:
          - {ip: 172.16.100.1, remote_as: 65100, description: internet-rtr}
          - {ip: 172.16.200.1, remote_as: 65200, description: DC2-BL-gold, route_map_out: DCI-OUT}
      # EVPN gateway to DC3 (RFC 9014 multi-domain). Needs EOS 4.36+.
      dci_gateway:
        domain_id: "1:1"
        remote_domain_id: "3:3"
        links:                 # metro underlay: only Lo0 + Lo1 are advertised across
          - {intf: Ethernet5, description: METRO-EVPN-DCI-to-dc3-border-leaf Ethernet5,
             ip: 172.16.230.0/31, peer_ip: 172.16.230.1, remote_as: 65300,
             neighbor_description: dc3-border-leaf-METRO-underlay}
        peers:                 # EVPN gateway session, Lo0 to Lo0
          - {ip: 10.3.250.15, remote_as: 65300, description: dc3-border-leaf-METRO-EVPN}
        stretched_vlans: [40]  # L2 extension; remote RD = Lo0:(10000+VLAN)

    # ==================================================================== DC2 (DR, L3 only)
    # No spines: dc2-border-leaf is the hub. Its downlinks + BGP to dc2-leaf1 are
    # GENERATED from dc2-leaf1's uplinks (same trick as the DC1 spines).
    dc2-border-leaf:
      role: border
      asn: 65200
      mgmt_ip: 192.168.1.233
      lo0: 10.1.250.15
      vtep: 10.1.255.15
      vlans: []
      external_interfaces:
        - {name: Ethernet4, description: DCI-to-DC1, mtu: 9214}
        - {name: Ethernet4.100, encapsulation: 100, vrf: gold, ip: 172.16.200.1/31}
      prefix_lists:
        DCI-OUT:
          - {seq: 10, action: permit, prefix: 10.0.0.0/8 le 24}
      route_maps:
        DCI-OUT:
          - {seq: 10, action: permit, match_prefix_list: DCI-OUT}
      vrf_neighbors:
        gold:
          - {ip: 172.16.200.0, remote_as: 65003, description: DC1-BL-gold, route_map_out: DCI-OUT}

    dc2-leaf1:
      role: leaf
      asn: 65201
      mgmt_ip: 192.168.1.231
      lo0: 10.1.250.11
      vtep: 10.1.255.11
      uplinks:
        - {peer: dc2-border-leaf, intf: Ethernet11, peer_intf: Ethernet1, ip: 10.1.1.1/31, peer_ip: 10.1.1.0}
      vlans: [60]
      access_ports:
        - {intf: Ethernet1, vlan: 60, description: DC2-host}

    # ==================================================================== DC3 (metro twin)
    dc3-border-leaf:
      role: border
      eos_train: "4.36"
      asn: 65300
      mgmt_ip: 192.168.1.228
      lo0: 10.3.250.15
      vtep: 10.3.255.15
      vlans: []
      vrf_loopbacks:           # a gateway with no SVIs needs an interface in the VRF
        - {id: 100, vrf: gold, ip: 10.3.100.1/32, description: VRF gold anchor / diagnostic}
      dci_gateway:
        domain_id: "3:3"
        remote_domain_id: "1:1"
        links:
          - {intf: Ethernet5, description: METRO-EVPN-DCI-to-DC1-border-leaf Ethernet5,
             ip: 172.16.230.1/31, peer_ip: 172.16.230.0, remote_as: 65003,
             neighbor_description: DC1-border-leaf-METRO-underlay}
        peers:
          - {ip: 10.0.250.15, remote_as: 65003, description: DC1-border-leaf-METRO-EVPN}
        stretched_vlans: [40]

    dc3-leaf1:
      role: leaf
      asn: 65301
      mgmt_ip: 192.168.1.229
      lo0: 10.3.250.11
      vtep: 10.3.255.11
      uplinks:
        - {peer: dc3-border-leaf, intf: Ethernet11, peer_intf: Ethernet1, ip: 10.3.1.1/31, peer_ip: 10.3.1.0}
      vlans: [40, 70]
      access_ports:
        - {intf: Ethernet1, vlan: 40, description: "VPC6 (VLAN 40, stretched)"}
        - {intf: Ethernet2, vlan: 70, description: "VPC7 (VLAN 70, DC3 home)"}
