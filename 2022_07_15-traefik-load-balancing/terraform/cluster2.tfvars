vms = [
  {
    name   = "traefik-ctrl1"
    cpu    = 1
    memory = 512
    ip     = 71
    groups = ["traefikee", "cluster2"]
    vars = {
      traefikee_role = "controller"
    }
  },
  {
    name   = "traefik-lb3"
    cpu    = 1
    memory = 512
    ip     = 72
    groups = ["keepalived", "traefikee", "cluster2"]
    vars = {
      role           = "master"
      traefikee_role = "proxy"
    }
  },
  {
    name   = "traefik-lb4"
    cpu    = 1
    memory = 512
    ip     = 73
    groups = ["keepalived", "traefikee", "cluster2"]
    vars = {
      role           = "backup"
      traefikee_role = "proxy"
    }
  },
  {
    name   = "kube-node1"
    cpu    = 1
    memory = 1024
    ip     = 74
    groups = ["kubernetes"]
    vars = {
      role = "server"
    }
  },
  {
    name   = "kube-node2"
    cpu    = 1
    memory = 1024
    ip     = 75
    groups = ["kubernetes"]
    vars = {
      role = "agent"
    }
  },
  {
    name   = "kube-node3"
    cpu    = 1
    memory = 1024
    ip     = 76
    groups = ["kubernetes"]
    vars = {
      role = "agent"
    }
  }
]
cluster = 2
vip     = 70
backends = [
  {
    ip   = "75"
    port = 80
  },
  {
    ip   = "76"
    port = 80
  }
]
keepalived_pass      = "tr@3fiK2"
keepalived_router_id = 43
keepalived_check     = "check_traefik"