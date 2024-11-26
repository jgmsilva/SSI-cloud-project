proxmox_endpoint = "192.168.122.29:8006"

proxmox_nodename = "myproxmox"

clientvm_object = {
  "vm1" = {
    name   = "vm1"
    role   = "web-server"
    memory = 512
  }
  # "vm2" = {
  #   name = "vm2"
  #   role = "database"
  #   memory = 512
  # }
}
