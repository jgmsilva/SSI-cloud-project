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
      password = "password"
      keys     = [trimspace(tls_private_key.ubuntu_vm_key.public_key_openssh)]

    }
    # user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config.id
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
  # url          = "https://cloud.centos.org/centos/8-stream/x86_64/images/CentOS-Stream-GenericCloud-8-latest.x86_64.qcow2"
  url       = "https://cloud.debian.org/images/cloud/bookworm/20230612-1409/debian-12-genericcloud-amd64-20230612-1409.qcow2"
  file_name = "debian12.img"
  # url = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
}

resource "tls_private_key" "ubuntu_vm_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
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

# resource "proxmox_virtual_environment_file" "user_data_cloud_config" {
#   content_type = "snippets"
#   datastore_id = "local"
#   node_name    = "pve"

#   source_raw {
#     data = <<-EOF
#     #cloud-config
#     hostname: vm1
#     users:
#       - default
#       - name: ansible
#         groups:
#           - sudo
#         shell: /bin/bash
#         ssh_authorized_keys:
#           - ${trimspace(tls_private_key.ubuntu_vm_key.public_key_openssh)}
#         sudo: ALL=(ALL) NOPASSWD:ALL
#     write_files:
#       - path: /etc/fstab
#         content: |
#           LABEL=cloudimg-rootfs   /    ext4   defaults    0 1
#     runcmd:
#       - "mkfs.ext4 /dev/vda1"
#       - "mkdir -p /mnt/data"
#       - "mount /dev/vda1 /mnt/data"
#       - "echo '/dev/vda1 /mnt/data ext4 defaults 0 1' >> /etc/fstab"
#       - apt update
#     EOF

#     file_name = "user-data-cloud-config.yaml"
#   }
# }
