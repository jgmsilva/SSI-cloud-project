[audit]
%{ for ip in audits ~}
${ip}
%{ endfor ~}

[client]
%{ for ip in clients ~}
${ip}
%{ endfor ~}
