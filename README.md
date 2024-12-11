# Local Cloud Infrastructure in PROXMOX

## Terraform
Promox provider: https://github.com/bpg/terraform-provider-proxmox

## Ansible
Reference for hardening playbook and roles: https://github.com/dev-sec/ansible-collection-hardening
###  Directories explanations

- ***roles/ :*** The directory containing all project roles.
    - ***roles/\*role-name\*/ :*** The Role configuration directory.
        - ***defaults/main.yml :*** Default variables for the role (lowest precedence).
        - ***tasks/main.yml :*** The main tasks file where you define what the role does step-by-step.
        - ***handlers/main.yml :*** Handlers triggered by task changes (e.g., restarting services).
        - ***templates/ :*** Directory for template files.

