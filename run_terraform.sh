#!/bin/bash
#
ANSIBLE_PLAYBOOK="./tf-playbook.yaml"
ANSIBLE_INVENTORY="./inventory.ini"

terraform plan
terraform apply -auto-approve

ansible-playbook $ANSIBLE_PLAYBOOK -i $ANSIBLE_INVENTORY
