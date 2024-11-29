[all:vars]
ansible_ssh_common_args = "-F ./ssh_config.local"

[audit]
%{ for ip in audits ~}
${ip}
%{ endfor ~}

[client]
%{ for ip in clients ~}
${ip}
%{ endfor ~}
