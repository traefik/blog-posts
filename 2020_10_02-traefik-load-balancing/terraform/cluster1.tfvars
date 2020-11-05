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
  }
]