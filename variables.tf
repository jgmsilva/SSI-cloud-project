variable "clientvm_object" {
  type = map(object({
    name = string
    role = string
    memory = number
  }))
}

variable "proxmox_nodename" {
  type = string
}

variable "proxmox_endpoint" {
  type = string
}
