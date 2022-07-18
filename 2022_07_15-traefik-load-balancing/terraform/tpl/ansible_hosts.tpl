[all]
%{ for vm in vms ~}
${vm.name} ansible_ssh_host=${cidrhost(subnet, vm.ip)} host_ip=${cidrhost(subnet, vm.ip)} host_name=${vm.name}
%{ endfor }

[all:vars]
gateway=${gateway}
mask=${mask}
nameserver=${nameserver}
ansible_ssh_common_args=-o StrictHostKeyChecking=no
ansible_python_interpreter=/usr/bin/python3


%{ for group in ["keepalived", "traefik", "traefikee", "fakeservice", "kubernetes", "bird", "cluster1", "cluster2", "cluster3"] }
[${group}]
%{ for vm in vms ~}
%{ if contains(vm.groups, group) ~}
${vm.name}%{ for key, value in vm.vars } ${key}=${value}%{ endfor}
%{ endif ~}
%{ endfor }
%{ endfor }
