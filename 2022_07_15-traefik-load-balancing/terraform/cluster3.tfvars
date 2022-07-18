vms = [
  {
    name   = "router-1"
    cpu    = 1
    memory = 512
    ip     = 81
    groups = ["bird", "cluster3"]
    vars = {
      role = "router"
    }
  },
  {
    name   = "traefik-ctrl2"
    cpu    = 1
    memory = 512
    ip     = 82
    groups = ["traefikee", "cluster3"]
    vars = {
      traefikee_role = "controller"
    }
  },
  {
    name   = "traefik-lb5"
    cpu    = 1
    memory = 512
    ip     = 83
    groups = ["bird", "traefikee", "cluster3"]
    vars = {
      role           = "client"
      traefikee_role = "proxy"
    }
  },
  {
    name   = "traefik-lb6"
    cpu    = 1
    memory = 512
    ip     = 84
    groups = ["bird", "traefikee", "cluster3"]
    vars = {
      role           = "client"
      traefikee_role = "proxy"
    }
  },
  {
    name   = "kube-node1"
    cpu    = 1
    memory = 1024
    ip     = 73
    groups = ["kubernetes"]
    vars = {
      role = "server"
    }
  },
  {
    name   = "kube-node2"
    cpu    = 1
    memory = 1024
    ip     = 74
    groups = ["kubernetes"]
    vars = {
      role = "agent"
    }
  },
  {
    name   = "kube-node3"
    cpu    = 1
    memory = 1024
    ip     = 75
    groups = ["kubernetes"]
    vars = {
      role = "agent"
    }
  }
]
cluster = 3
vip     = 80
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