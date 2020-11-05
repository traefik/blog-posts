terraform {
  required_providers {
    libvirt = {
      source  = "github.com/dmacvicar/libvirt"
      version = "0.6.2"
    }
  }
}

# VMs as map
variable "vms" {
  type    = list
  default = []
}

variable "ssh_key" {
  type    = string
  default = "~/.ssh/id_rsa"
}

variable "libvirt_uri" {
   type    = string
   default = "qemu:///system"
}

provider "libvirt" {
 uri   = var.libvirt_uri
}

resource "libvirt_volume" "disk" {
  count = length(var.vms)
  name  = "${var.vms[count.index].name}.qcow2"
  pool = "images"
  base_volume_pool = "templates"
  base_volume_name = "debian10-traefik.qcow2"
 #  source = "templates/${lookup(var.vms[count.index], "image", "debian10-traefik")}.qcow2"
}

resource "libvirt_domain" "vm" {
  count = length(var.vms)
  name  = var.vms[count.index].name

  qemu_agent = true
  autostart = true

  vcpu   = lookup(var.vms[count.index], "cpu", 1)
  memory = lookup(var.vms[count.index], "memory", 512)

  network_interface {
    bridge = "br0"
    wait_for_lease = true
  }

  boot_device {
    dev = ["hd"]
  }

  disk {
    volume_id = libvirt_volume.disk[count.index].id
  }

  console {
    type = "pty"
    target_type = "serial"
    target_port = "0"
  }

  provisioner "ansible" {
    when = create

    connection {
      type = "ssh"
      host = self.network_interface.0.addresses.0
      user = "root"
      private_key = file(var.ssh_key)
    }

    ansible_ssh_settings {
      connect_timeout_seconds = 10
      connection_attempts = 10
      ssh_keyscan_timeout = 60
      insecure_no_strict_host_key_checking = false
      insecure_bastion_no_strict_host_key_checking = false
      user_known_hosts_file = ""
      bastion_user_known_hosts_file = ""
    }

    plays {
      playbook {
        file_path = "../ansible/post_install.yml"
        force_handlers = false
        tags = ["base"]
      }
      hosts = [self.network_interface.0.addresses.0]
      extra_vars = {
        host_ip = "${var.vms[count.index].ip}"
        host_name = "${var.vms[count.index].name}.traefik.local"
      }
    }
  }
}

resource "local_file" "ansible_hosts" {
  content = templatefile("./tpl/ansible_hosts.tpl", { vms = var.vms })
  filename = "../ansible/traefik_inventory"
  file_permission = 0644
  directory_permission = 0755
}

terraform {
  required_version = ">= 0.13"
}
