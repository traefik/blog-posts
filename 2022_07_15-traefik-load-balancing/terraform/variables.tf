variable "vms" {
  type    = list
  default = []
}

variable "cluster" {
  type    = number
  default = 1
}

variable "keepalived_pass" {
  type    = string
  default = null
}

variable "vip" {
  type    = number
  default = null
}

variable "keepalived_router_id" {
  type    = number
  default = null
}

variable "keepalived_check" {
  type    = string
  default = null
}

variable "backends" {
  type    = list
  default = null
}

variable "network_bridge" {
  type    = string
  default = "virbr0"
}

variable "subnet" {
  type    = string
  default = "192.168.1.0/24"
}

variable "ssh_key" {
  type    = string
  default = "~/.ssh/id_rsa"
}

variable "libvirt_uri" {
  type    = string
  default = "qemu:///system"
}

variable "templates_pool" {
  type    = string
  default = "templates"
}

variable "template_img" {
  type    = string
  default = "debian11-traefik.qcow2"
}