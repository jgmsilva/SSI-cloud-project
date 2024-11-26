terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.68.0"
    }
  }
}

provider "proxmox" {
  endpoint = "https://${var.proxmox_endpoint}/api2/json"
  username = "root@pam"
  password = "proxmox"
  insecure = true
  ssh {
    agent = true
  }
}
