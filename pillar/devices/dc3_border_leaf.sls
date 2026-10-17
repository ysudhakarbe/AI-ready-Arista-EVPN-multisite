{% import_yaml 'devices/_creds.yaml' as c %}
hostname: dc3-border-leaf
proxy:
  proxytype: napalm
  driver: eos
  host: 192.168.1.228
  username: {{ c.username }}
  passwd: {{ c.passwd }}
  optional_args:
    transport: https
