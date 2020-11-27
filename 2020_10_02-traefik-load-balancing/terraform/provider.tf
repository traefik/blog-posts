terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.6.3"
    }
  }
  required_version = ">= 0.13"
}

provider "libvirt" {
  uri = var.libvirt_uri
}