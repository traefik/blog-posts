vms = [
  {
    name = "router-1"
    cpu = 1
    memory = 512
    ip = "192.168.1.81"
    groups = ["bird", "cluster3"]
    vars = {
        role = "router"
    }
  },
  {
    name = "traefik-ctrl2"
    cpu = 1
    memory = 512
    ip = "192.168.1.82"
    groups = ["traefikee", "cluster3"]
    vars = {
        traefikee_role = "controller"
    }
  },
  {
    name = "traefik-lb5"
    cpu = 1
    memory = 512
    ip = "192.168.1.83"
    groups = ["bird", "traefikee", "cluster3"]
    vars = {
        role = "client"
        traefikee_role = "proxy"
    }
  },
  {
    name = "traefik-lb6"
    cpu = 1
    memory = 512
    ip = "192.168.1.84"
    groups = ["bird", "traefikee", "cluster3"]
    vars = {
         role = "client"
         traefikee_role = "proxy"
    }
  },
  {
    name = "kube-node1"
    cpu = 1
    memory = 1024
    ip = "192.168.1.73"
    groups = ["kubernetes"]
    vars = {
        role = "server"
    }
  },
  {
    name = "kube-node2"
    cpu = 1
    memory = 1024
    ip = "192.168.1.74"
    groups = ["kubernetes"]
    vars = {
        role = "agent"
    }
   },
   {
    name = "kube-node3"
    cpu = 1
    memory = 1024
    ip = "192.168.1.75"
    groups = ["kubernetes"]
    vars = {
        role = "agent"
    }
  }
]