vms = [
  {
    name = "traefik-lb1"
    cpu = 1
    memory = 512
    ip = "192.168.1.61"
    groups = ["keepalived", "traefik", "fake-service", "cluster1"]
    vars = {
         role = "master"
    }
  },
  {
    name = "traefik-lb2"
    cpu = 1
    memory = 512
    ip = "192.168.1.62"
    groups = ["keepalived", "traefik", "fake-service", "cluster1"]
    vars = {
         role = "backup"
    }
  },

  {
    name = "traefik-lb3"
    cpu = 1
    memory = 512
    ip = "192.168.1.71"
    groups = ["keepalived", "traefik", "cluster2"]
    vars = {
        role = "master"
    }
  },
  {
    name = "traefik-lb4"
    cpu = 1
    memory = 512
    ip = "192.168.1.72"
    groups = ["keepalived", "traefik", "cluster2"]
    vars = {
         role = "backup"
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