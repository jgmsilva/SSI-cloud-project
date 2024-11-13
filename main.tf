terraform {
  required_version = ">= 0.15"
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
    }
  }
}

provider "proxmox" {
 pm_api_url   = "https://127.0.0.1:8006/api2/json"
 pm_user      = "root@pam"
 pm_password  = ""
 pm_tls_insecure = true
}

resource "proxmox_vm_qemu" "my_vm" {
 name       = "my-vm"
 target_node = "pve"
 clone      = "debian-template"
 storage    = "local-lvm"
 cores      = 1
 memory     = 1024
}

