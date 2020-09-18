[all]
%{ for vm in vms ~}
${vm.name} ansible_ssh_host=${vm.ip} host_ip=${vm.ip} host_name=${vm.name} ansible_ssh_common_args='-o StrictHostKeyChecking=no'
%{ endfor ~}

%{ for group in ["keepalived", "traefik", "fake-service", "kubernetes", "cluster1", "cluster2"] }
[${group}]
%{ for vm in vms ~}
%{ if contains(vm.groups, group) ~}
${vm.name}%{ for key, value in vm.vars } ${key}=${value}%{ endfor}
%{ endif ~}
%{ endfor }
%{ endfor }
