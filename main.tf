terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.66.3"
    }
  }
}

provider "proxmox" {
  endpoint = "https://192.168.122.243:8006/api2/json"
  username = "root@pam"
  password = "proxmox"
  insecure = true
  ssh {
    agent = true
  }
}
resource "tls_private_key" "rsa-4096-audit-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "proxmox_virtual_environment_vm" "audit_vm" {
  name            = "audit"
  node_name       = var.proxmox_nodename
  stop_on_destroy = true
  initialization {

    user_account {
      # do not use this in production, configure your own ssh key instead!
      username = "user"
      password = "password"
    }
  }

  disk {
    interface    = "virtio0"
    size         = 20
    datastore_id = "local-lvm"
    file_format  = "raw"
  }

  cpu {
    cores = 2
    type  = "x86-64-v2-AES" # recommended for modern CPUs
  }

  memory {
    dedicated = 2048
    floating  = 2048 # set equal to dedicated to enable ballooning
  }
}


resource "proxmox_virtual_environment_vm" "client_vm" {
  for_each  = try(var.clientvm_object, {})
  name      = each.value.name
  node_name = var.proxmox_nodename

  initialization {
    user_account {
      # do not use this in production, configure your own ssh key instead!
      username = "user"
      password = "password"
    }
  }
  stop_on_destroy = true
  # clone {
  #   vm_id = 100
  # }
  disk {
    interface    = "virtio0"
    size         = 20
    datastore_id = "local-lvm"
    iothread     = true
    discard      = "on"
    file_id      = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
  }

  cpu {
    cores = 2
    type  = "x86-64-v2-AES" # recommended for modern CPUs
  }

  memory {
    dedicated = each.value.memory
    floating  = each.value.memory # set equal to dedicated to enable ballooning
  }

}


resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "pve"
  url          = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
}
