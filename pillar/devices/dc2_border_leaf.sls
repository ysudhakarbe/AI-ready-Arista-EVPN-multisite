{% import_yaml 'devices/_creds.yaml' as c %}
hostname: dc2-border-leaf
proxy:
  proxytype: napalm
  driver: eos
  host: 192.168.1.233
  username: {{ c.username }}
  passwd: {{ c.passwd }}
  optional_args:
    transport: https
