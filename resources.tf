


# Use null_resource to wait for each server to be ready and run Ansible playbook
resource "null_resource" "run_ansible_playbook" {
  for_each   = try(var.clientvm_object, {})
  depends_on = [proxmox_virtual_environment_vm.client_vm]
  provisioner "local-exec" {
    command     = "until nc -zv ${each.value.ipv4_address} 22; do echo 'Waiting for SSH to be available...'; sleep 5; done"
    working_dir = path.module
  }
  provisioner "local-exec" {
    command     = "ansible-playbook -i ./inventory.ini ./playbook.yaml"
    working_dir = path.module
  }
}
