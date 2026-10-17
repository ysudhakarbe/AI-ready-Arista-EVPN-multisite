{% import_yaml 'devices/_creds.yaml' as c %}
hostname: dc3-leaf1
proxy:
  proxytype: napalm
  driver: eos
  host: 192.168.1.229
  username: {{ c.username }}
  passwd: {{ c.passwd }}
  optional_args:
    transport: https
