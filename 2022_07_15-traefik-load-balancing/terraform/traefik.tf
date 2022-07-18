resource "libvirt_network" "network" {
  name      = "traefik"
  mode      = "nat"
  domain    = "traefik.local"
  addresses = [var.subnet]
  dhcp {
    enabled = true
  }
  dns {
    enabled    = true
    local_only = true
  }
}

resource "libvirt_pool" "images" {
  name = "images"
  type = "dir"
  path = "/var/lib/libvirt/images/images"
}

resource "libvirt_volume" "disk" {
  count            = length(var.vms)
  name             = "${var.vms[count.index].name}.qcow2"
  pool             = libvirt_pool.images.name
  base_volume_name = var.template_img
  base_volume_pool = var.templates_pool
}

resource "libvirt_domain" "vm" {
  count = length(var.vms)
  name  = var.vms[count.index].name

  autostart  = true

  vcpu   = lookup(var.vms[count.index], "cpu", 1)
  memory = lookup(var.vms[count.index], "memory", 512)

  network_interface {
    network_id     = libvirt_network.network.id
    network_name   = libvirt_network.network.name
    wait_for_lease = true
  }

  boot_device {
    dev = ["hd"]
  }

  disk {
    volume_id = libvirt_volume.disk[count.index].id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  provisioner "ansible" {
    when = create

    connection {
      type        = "ssh"
      host        = self.network_interface.0.addresses.0
      user        = "root"
      private_key = file(var.ssh_key)
    }

    ansible_ssh_settings {
      connect_timeout_seconds                      = 10
      connection_attempts                          = 10
      ssh_keyscan_timeout                          = 60
      insecure_no_strict_host_key_checking         = false
      insecure_bastion_no_strict_host_key_checking = false
      user_known_hosts_file                        = ""
      bastion_user_known_hosts_file                = ""
    }

    plays {
      playbook {
        file_path      = "../ansible/post_install.yml"
        force_handlers = false
        tags           = ["base"]
      }
      hosts = [self.network_interface.0.addresses.0]
      extra_vars = {
        host_ip    = cidrhost(var.subnet, var.vms[count.index].ip)
        host_name  = "${var.vms[count.index].name}.traefik.local"
        gateway    = cidrhost(var.subnet, 1)
        mask       = cidrnetmask(var.subnet)
        nameserver = cidrhost(var.subnet, 1)
      }
    }
  }
}

resource "local_file" "ansible_hosts" {
  content = templatefile("./tpl/ansible_hosts.tpl", {
    vms        = var.vms,
    subnet     = var.subnet,
    gateway    = cidrhost(var.subnet, 1),
    mask       = cidrnetmask(var.subnet),
    nameserver = cidrhost(var.subnet, 1)
  })
  filename             = "../ansible/traefik_inventory"
  file_permission      = 0644
  directory_permission = 0755
}

resource "local_file" "group_vars" {
  content = templatefile("./tpl/group_vars.tpl", {
    subnet          = var.subnet,
    vip             = var.vip,
    keepalived_conf = "%{if var.keepalived_pass != null}keepalived_pass: \"${var.keepalived_pass}\"\n%{endif}%{if var.keepalived_router_id != null}keepalived_router_id: ${var.keepalived_router_id}\n%{endif}%{if var.keepalived_check != null}keepalived_check: \"${var.keepalived_check}\"\n%{endif}",
    backends        = var.backends
  })
  filename             = "../ansible/group_vars/cluster${var.cluster}.yaml"
  file_permission      = 0644
  directory_permission = 0755
}