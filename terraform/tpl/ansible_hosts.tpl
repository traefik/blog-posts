[all]
%{ for index, vm in vms ~}
${vm.name} ansible_ssh_host=${vm.ip} host_ip=${vm.ip} host_name=${vm.name}
%{ endfor ~}

[keepalived]
%{ for index, vm in vms ~}
%{ if contains(vm.groups, "keepalived") ~}
${vm.name} role=${vm.role}
%{ endif ~}
%{ endfor ~}