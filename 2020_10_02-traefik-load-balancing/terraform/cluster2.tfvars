vms = [
  {
    name = "traefik-ctrl1"
    cpu = 1
    memory = 512
    ip = "192.168.1.71"
    groups = ["traefikee", "cluster2"]
    vars = {
        traefikee_role = "controller"
    }
  },
  {
    name = "traefik-lb3"
    cpu = 1
    memory = 512
    ip = "192.168.1.72"
    groups = ["keepalived", "traefikee", "cluster2"]
    vars = {
        role = "master"
        traefikee_role = "proxy"
    }
  },
  {
    name = "traefik-lb4"
    cpu = 1
    memory = 512
    ip = "192.168.1.73"
    groups = ["keepalived", "traefikee", "cluster2"]
    vars = {
         role = "backup"
         traefikee_role = "proxy"
    }
  },
  {
    name = "kube-node1"
    cpu = 1
    memory = 1024
    ip = "192.168.1.74"
    groups = ["kubernetes"]
    vars = {
        role = "server"
    }
  },
  {
    name = "kube-node2"
    cpu = 1
    memory = 1024
    ip = "192.168.1.75"
    groups = ["kubernetes"]
    vars = {
        role = "agent"
    }
   },
   {
    name = "kube-node3"
    cpu = 1
    memory = 1024
    ip = "192.168.1.76"
    groups = ["kubernetes"]
    vars = {
        role = "agent"
    }
  }
]