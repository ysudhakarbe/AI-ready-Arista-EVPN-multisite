base:
  # every switch gets the fabric data; the router does not need it
  'not internet-rtr':
    - match: compound
    - fabric
    - users          # password hashes, git-ignored (pillar/users.sls)
  # ---- DC1
  'spine1':          [devices.spine1]
  'spine2':          [devices.spine2]
  'leaf1':           [devices.leaf1]
  'leaf2':           [devices.leaf2]
  'leaf3':           [devices.leaf3]
  'leaf4':           [devices.leaf4]
  'leaf5':           [devices.leaf5]
  'dc1-border-leaf': [devices.dc1_border_leaf]
  # ---- DC2
  'dc2-border-leaf': [devices.dc2_border_leaf]
  'dc2-leaf1':       [devices.dc2_leaf1]
  # ---- DC3
  'dc3-border-leaf': [devices.dc3_border_leaf]
  'dc3-leaf1':       [devices.dc3_leaf1]
  # ---- edge
  'internet-rtr':    [devices.internet_rtr]
