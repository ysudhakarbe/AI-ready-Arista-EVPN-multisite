{% import_yaml 'devices/_creds.yaml' as c %}
hostname: spine2
proxy:
  proxytype: napalm
  driver: eos
  host: 192.168.1.212
  username: {{ c.username }}
  passwd: {{ c.passwd }}
  optional_args:
    transport: https
