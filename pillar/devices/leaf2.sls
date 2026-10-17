{% import_yaml 'devices/_creds.yaml' as c %}
hostname: leaf2
proxy:
  proxytype: napalm
  driver: eos
  host: 192.168.1.222
  username: {{ c.username }}
  passwd: {{ c.passwd }}
  optional_args:
    transport: https
