{% import_yaml 'devices/_creds.yaml' as c %}
hostname: dc2-leaf1
proxy:
  proxytype: napalm
  driver: eos
  host: 192.168.1.231
  username: {{ c.username }}
  passwd: {{ c.passwd }}
  optional_args:
    transport: https
