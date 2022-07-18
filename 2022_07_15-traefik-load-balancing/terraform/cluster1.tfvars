vms = [
  {
    name   = "traefik-lb1"
    cpu    = 1
    memory = 512
    ip     = 61
    groups = ["keepalived", "traefik", "fakeservice", "cluster1"]
    vars = {
      role = "master"
    }
  },
  {
    name   = "traefik-lb2"
    cpu    = 1
    memory = 512
    ip     = 62
    groups = ["keepalived", "traefik", "fakeservice", "cluster1"]
    vars = {
      role = "backup"
    }
  }
]
cluster = 1
vip     = 60
backends = [
  {
    ip   = "127.0.0.1"
    port = 8888
  }
]
keepalived_pass      = "tr@3fiK1"
keepalived_router_id = 42
keepalived_check     = "check_traefik"