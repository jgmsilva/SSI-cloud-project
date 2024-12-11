resource "proxmox_virtual_environment_vm" "client_vm" {
  for_each  = try(var.servervm_object, {})
  name      = each.value.name
  node_name = var.proxmox_nodename
  tags      = each.value.tags

  initialization {

    ip_config {
      ipv4 {
        address = "${each.value.ipv4_address}/24"
        gateway = "192.168.122.1"
      }
    }

    user_account {
      username = "ansible"
      keys     = [trimspace(tls_private_key.ubuntu_vm_key.public_key_openssh)]
    }
  }
  stop_on_destroy = true

  disk {
    interface    = "virtio0"
    size         = each.value.disk_size
    datastore_id = "local-lvm"
    iothread     = true
    discard      = "on"
    file_id      = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
  }

  cpu {
    cores = each.value.cpu_cores
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
  node_name    = var.proxmox_nodename
  url          = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
}

resource "tls_private_key" "ubuntu_vm_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

locals {
  inventory_groups = {
    audits  = [for vm in values(proxmox_virtual_environment_vm.client_vm) : var.servervm_object[vm.name].ipv4_address if contains(vm.tags, "audit")]
    servers = [for vm in values(proxmox_virtual_environment_vm.client_vm) : var.servervm_object[vm.name].ipv4_address if contains(vm.tags, "web-server")]
  }
}
resource "local_file" "ansible_inventory" {
  filename        = "./inventory.ini"
  file_permission = "0666"
  content         = templatefile("./templates/inventory.tpl", local.inventory_groups)
}
resource "local_file" "ansible_private_key" {
  filename        = "./keys/ansible_key.pem"
  content         = tls_private_key.ubuntu_vm_key.private_key_openssh
  file_permission = "0600"
}

resource "local_file" "ansible_public_key" {
  filename        = "./keys/ansible_key.pub"
  content         = trimspace(tls_private_key.ubuntu_vm_key.public_key_openssh)
  file_permission = "0666"
}

resource "local_file" "known_hosts" {
  filename        = "./terraform_known_hosts"
  content         = ""
  file_permission = "0666"
}
