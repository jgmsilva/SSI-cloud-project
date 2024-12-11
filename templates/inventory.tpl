[all:vars]
ansible_ssh_common_args = "-F ./ssh_config.local"

[audit]
%{ for ip in audits ~}
${ip}
%{ endfor ~}

[server]
%{ for ip in servers ~}
${ip}
%{ endfor ~}
