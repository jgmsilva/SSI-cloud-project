proxmox_endpoint = "192.168.122.139:8006"

proxmox_nodename = "pve"

servervm_object = {
  "vm1" = {
    name         = "vm1"
    tags         = ["web-server"]
    ipv4_address = "192.168.122.245"
    memory       = 1024
    cpu_cores    = 1
    disk_size    = 20
  }
  "vm2" = {
    name         = "vm2"
    tags         = ["audit"]
    ipv4_address = "192.168.122.246"
    memory       = 3072
    cpu_cores    = 3
    disk_size    = 40
  }
}
