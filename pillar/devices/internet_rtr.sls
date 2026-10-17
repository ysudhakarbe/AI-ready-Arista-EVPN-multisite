{% import_yaml 'devices/_creds.yaml' as c %}
# Cisco IOSv edge router - NOT part of the 'fabric' state (no EVPN template).
# Managed with NAPALM 'ios' over SSH: backups, show commands, drift check, merges.
hostname: internet-rtr
proxy:
  proxytype: napalm
  driver: ios
  host: 192.168.1.232
  username: {{ c.username }}
  passwd: {{ c.passwd }}
  optional_args:
    transport: ssh
    global_delay_factor: 2      # IOSv is slow; avoids netmiko timeouts
