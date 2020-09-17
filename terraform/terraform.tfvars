vms = [
  {
    name = "traefik-lb1"
    cpu = 1
    memory = 1024
    ip = "192.168.1.61"
    groups = ["keepalived"]
    role = "master"
  },
  {
    name = "traefik-lb2"
    cpu = 1
    memory = 1024
    ip = "192.168.1.62"
    groups = ["keepalived"]
    role = "backup"
  }
]