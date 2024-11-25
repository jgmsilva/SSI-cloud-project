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

resource "proxmox_virtual_environment_vm" "audit_vm" {
  name            = "audit"
  node_name       = var.proxmox_nodename
  stop_on_destroy = true

  initialization {

    ip_config {
      ipv4 {
        address = "192.168.3.234/24"
        gateway = "192.168.3.1"
      }
    }

    user_account {
      keys     = [trimspace(tls_private_key.ubuntu_vm_key.public_key_openssh)]
      username = "ubuntu-audit"
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

  network_device {
    bridge = "vmbr0"
  }

}


resource "proxmox_virtual_environment_vm" "client_vm" {
  for_each  = try(var.clientvm_object, {})
  name      = each.value.name
  node_name = var.proxmox_nodename

  initialization {

    ip_config {
      ipv4 {
        address = "192.168.3.233/24"
        gateway = "192.168.3.1"
      }
    }

    user_account {
      # do not use this in production, configure your own ssh key instead!
      username = "ubuntu_vm"
      password = "password"
      keys = [trimspace(tls_private_key.ubuntu_vm_key.public_key_openssh)]
    }
  }
  stop_on_destroy = true

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

  network_device {
    bridge = "vmbr0"
  }


}


resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "pve"
  url          = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
}

resource "tls_private_key" "ubuntu_vm_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

output "ubuntu_vm_private_key" {
  value     = tls_private_key.ubuntu_vm_key.private_key_pem
  sensitive = true
}

output "ubuntu_vm_public_key" {
  value = tls_private_key.ubuntu_vm_key.public_key_openssh
}
