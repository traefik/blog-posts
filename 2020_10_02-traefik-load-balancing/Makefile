LOCAL_BIN=~/.local/bin/
PACKER_VERSION=1.6.2
TERRAFORM_PLUGIN_DIR=~/.terraform.d/plugins
TERRAFORM_VERSION=0.13.3
TERRAFORM_LIBVIRT_VERSION=0.6.2
TERRAFORM_ANSIBLE_VERSION=2.3.3
ANSIBLE_VERSION=2.9.13
LIBVIRT_HYPERVISOR_URI="qemu:///system"
LIBVIRT_IMAGES_POOL="templates"
LIBVIRT_IMAGE_NAME="debian10-traefik.qcow2"
ROOT_PASSWORD="traefik"
$(eval SSH_IDENTITY=$(shell find ~/.ssh/ -name 'id_*' -not -name '*.pub' | head -n 1))
CLUSTER=1
TRAEFIKEE_LICENSE="N/A"

all:

check-env:
	@(which unzip 2>&1 > /dev/null) || (echo "unzip is not in your PATH" && exit 1)
	@(which curl 2>&1 > /dev/null) || (echo "curl is not in your PATH" && exit 1)
	@(which virsh 2>&1 > /dev/null) || (echo "virsh is not in your PATH" && exit 1)
	@(terraform version 2>&1 | grep -E 'v0.1([4-9].[0-9]|3.[3-9])' > /dev/null) || (echo "terraform is not in your PATH or is not up to date" && exit 1)
	@(packer version 2>&1 | grep -E 'v1.([7-9].[0-9]|6.[2-9])' > /dev/null) || (echo "packer is not in your PATH or is not up to date" && exit 1)
	@(ansible --version | head -n 1 | grep -E '(2.9.(1[3-9]|[2-9][0-9])|[3-9].[0-9].[0-9])' > /dev/null) || (echo "packer is not in your PATH or is not up to date" && exit 1)
	@(which kubectl 2>&1 > /dev/null) || (echo "kubectl is not in your PATH" && exit 1)
	@$(eval  ANSIBLE_PYTHON_VERSION = $(shell ansible --version | grep 'python version' | awk '{ print $$4 }' | awk -F '.' '{ print $$1 }'))
	@(which python${ANSIBLE_PYTHON_VERSION} 2>&1 > /dev/null) || (echo "python${ANSIBLE_PYTHON_VERSION} is not in your PATH" && exit 1)
	@(which pip${ANSIBLE_PYTHON_VERSION} 2>&1 > /dev/null) || (echo "pip${ANSIBLE_PYTHON_VERSION} is not in your PATH" && exit 1)
	@(pip${ANSIBLE_PYTHON_VERSION} freeze | grep -E 'openshift==0.(1[1-9].[2-9]|[2-9][0-9].[0-9])' > /dev/null) || (echo "openshift>=0.11.2 is not installed as a python${ANSIBLE_PYTHON_VERSION} module" && exit 1)
	@(pip${ANSIBLE_PYTHON_VERSION} freeze | grep -E 'kubernetes==1[1-9].[0-9].[0-9]' > /dev/null) || (echo "kubernetes>=11.0.0 is not installed as a python${ANSIBLE_PYTHON_VERSION} module" && exit 1)
	@echo "You're ready to play!"

my-linux-env: create-env install-packer install-terraform install-terraform-plugins install-ansible

create-env:
	test -d $(LOCAL_BIN)|| mkdir -p $(LOCAL_BIN)
	echo ${PATH} | grep $(LOCAL_BIN) || (echo 'export PATH=$$PATH:~/.local/bin/' >> ~/.bashrc; . ~/.bashrc)

install-packer:
	test -f $(LOCAL_BIN)packer || \
	(curl https://releases.hashicorp.com/packer/$(PACKER_VERSION)/packer_$(PACKER_VERSION)_linux_amd64.zip -o /tmp/packer_$(PACKER_VERSION)_linux_amd64.zip; \
	unzip /tmp/packer_$(PACKER_VERSION)_linux_amd64.zip -d $(LOCAL_BIN); \
	rm -f /tmp/packer_$(PACKER_VERSION)_linux_amd64.zip); \
	chmod +x $(LOCAL_BIN)packer

install-terraform:
	test -f $(LOCAL_BIN)terraform || \
	(curl -q https://releases.hashicorp.com/terraform/$(TERRAFORM_VERSION)/terraform_$(TERRAFORM_VERSION)_linux_amd64.zip -o /tmp/terraform_$(TERRAFORM_VERSION)_linux_amd64.zip; \
	unzip /tmp/terraform_$(TERRAFORM_VERSION)_linux_amd64.zip -d $(LOCAL_BIN); \
	rm -f /tmp/terraform_$(TERRAFORM_VERSION)_linux_amd64.zip); \
	chmod +x $(LOCAL_BIN)terraform

install-ansible:
	pip3 freeze | grep ansible==$(ANSIBLE_VERSION) || pip3 install ansible kubernetes openshift

install-terraform-plugins:
	test -d $(TERRAFORM_PLUGIN_DIR)/github.com/dmacvicar/libvirt/$(TERRAFORM_LIBVIRT_VERSION)/linux_amd64/ || mkdir -p $(TERRAFORM_PLUGIN_DIR)/github.com/dmacvicar/libvirt/$(TERRAFORM_LIBVIRT_VERSION)/linux_amd64/; \
	test -f $(TERRAFORM_PLUGIN_DIR)/github.com/dmacvicar/libvirt/$(TERRAFORM_LIBVIRT_VERSION)/linux_amd64/terraform-provider-libvirt || \
	(curl https://github.com/dmacvicar/terraform-provider-libvirt/releases/download/v$(TERRAFORM_LIBVIRT_VERSION)/terraform-provider-libvirt-$(TERRAFORM_LIBVIRT_VERSION)+git.1585292411.8cbe9ad0.Ubuntu_18.04.amd64.tar.gz -o /tmp/terraform-provider-libvirt-$(TERRAFORM_LIBVIRT_VERSION).tar.gz && tar xfvz /tmp/terraform-provider-libvirt-$(TERRAFORM_LIBVIRT_VERSION).tar.gz -C $(TERRAFORM_PLUGIN_DIR)/github.com/dmacvicar/libvirt/$(TERRAFORM_LIBVIRT_VERSION)/linux_amd64/ && rm -f /tmp/terraform-provider-libvirt-$(TERRAFORM_LIBVIRT_VERSION).tar.gz)
	test -f $(TERRAFORM_PLUGIN_DIR)/terraform-provisioner-ansible || \
	(curl https://github.com/radekg/terraform-provisioner-ansible/releases/download/v$(TERRAFORM_ANSIBLE_VERSION)/terraform-provisioner-ansible-linux-amd64_v$(TERRAFORM_ANSIBLE_VERSION) -o $(TERRAFORM_PLUGIN_DIR)/terraform-provisioner-ansible && chmod +x $(TERRAFORM_PLUGIN_DIR)/terraform-provisioner-ansible)

image: build-image upload-image

build-image:
	rm -rf  packer/output
	$(eval CRYPTED_PASSWORD = $$(shell openssl passwd -6 "$(ROOT_PASSWORD)"))
	sed -i -r 's@^(d-i passwd\/root-password-crypted password).*@\1 $(CRYPTED_PASSWORD)@g' packer/preseed/debian10.txt
	cd packer && ROOT_PASSWORD=$(ROOT_PASSWORD) SSH_PUB_KEY="$(shell cat $(SSH_IDENTITY).pub)" packer build base.json

upload-image:
	$(eval  size = $(shell stat -Lc%s packer/output/debian10))
	- virsh -c $(LIBVIRT_HYPERVISOR_URI) vol-list $(LIBVIRT_IMAGES_POOL) | grep $(LIBVIRT_IMAGE_NAME) && virsh -c $(LIBVIRT_HYPERVISOR_URI) vol-delete --pool $(LIBVIRT_IMAGES_POOL) $(LIBVIRT_IMAGE_NAME)
	virsh -c $(LIBVIRT_HYPERVISOR_URI) vol-create-as $(LIBVIRT_IMAGES_POOL) $(LIBVIRT_IMAGE_NAME) $(size) --format qcow2 && \
	virsh -c $(LIBVIRT_HYPERVISOR_URI) vol-upload --pool $(LIBVIRT_IMAGES_POOL) $(LIBVIRT_IMAGE_NAME) packer/output/debian10

import-kube-nodes:
	[ $(CLUSTER) -eq 3 ] && { \
	cd terraform ; \
	[ -f cluster2.tfstate ] && ! [ -f cluster3.tfstate ] && { \
	cp cluster2.tfstate cluster2.tfstate.copy; \
	for i in 3 4 5 ; do \
		terraform state mv -state=cluster2.tfstate.copy -state-out=cluster3.tfstate libvirt_domain.vm[$$i] libvirt_domain.vm[$$((i+1))]; \
	done; \
	rm -f cluster2.tfstate.copy ; \
	} \
	} || echo "not importing"

create-vms: import-kube-nodes
	cd terraform && terraform init && terraform apply -auto-approve -var "libvirt_uri=$(LIBVIRT_HYPERVISOR_URI)" -var "ssh_key=$(SSH_IDENTITY)" -var-file="cluster$(CLUSTER).tfvars" -state="cluster$(CLUSTER).tfstate"

run-playbook: create-vms
	cd ansible && ansible-playbook -u root -i traefik_inventory -e "traefikee_license_key=$(TRAEFIKEE_LICENSE_KEY)" site.yml
