terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.66.3"
    }
  }
}

provider "proxmox" {
 endpoint  = "https://192.168.122.243:8006/api2/json"
 username  = "root@pam"
 password  = ""
 insecure  = true
 ssh {
    agent = true
 }
}

resource "proxmox_virtual_environment_vm" "my_vm" {
 name       = "my-vm"
 node_name  = "pve"
 clone {
    vm_id   = 100
 }
 disk {
    interface    = "virtio0"
    size         = 20
    datastore_id = "local-lvm"
    file_format = "raw
 }

 cpu {
    cores        = 2
    type         = "x86-64-v2-AES"  # recommended for modern CPUs
  }

  memory {
    dedicated = 2048
    floating  = 2048 # set equal to dedicated to enable ballooning
  }

}

