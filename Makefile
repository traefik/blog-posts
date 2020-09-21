LOCAL_BIN=~/.local/bin/
PACKER_VERSION=1.6.2
TERRAFORM_PLUGIN_DIR=~/.terraform.d/plugins
TERRAFORM_VERSION=0.13.2
TERRAFORM_LIBVIRT_VERSION=0.6.2
TERRAFORM_ANSIBLE_VERSION=2.3.3
ANSIBLE_VERSION=2.9.13
LIBVIRT_HYPERVISOR_URI="qemu:///system"
LIBVIRT_IMAGES_POOL="templates"
LIBVIRT_IMAGE_NAME="debian10-traefik.qcow2"
ROOT_PASSWORD="traefik"
$(eval SSH_IDENTITY=$(shell find ~/.ssh/ -name 'id_*' -not -name '*.pub' | head -n 1))
CLUSTER=1

all:

myenv: create-env install-packer install-terraform install-terraform-plugins install-ansible

create-env:
	test -d $(LOCAL_BIN)|| mkdir -p $(LOCAL_BIN)
	echo ${PATH} | grep $(LOCAL_BIN) || (echo 'export PATH=$$PATH:~/.local/bin/' >> ~/.bashrc; . ~/.bashrc)

install_packer:
	test -f $(LOCAL_BIN)packer || \
	(wget -q https://releases.hashicorp.com/packer/$(PACKER_VERSION)/packer_$(PACKER_VERSION)_linux_amd64.zip -O /tmp/packer_$(PACKER_VERSION)_linux_amd64.zip; \
	unzip /tmp/packer_$(PACKER_VERSION)_linux_amd64.zip -d $(LOCAL_BIN); \
	rm -f /tmp/packer_$(PACKER_VERSION)_linux_amd64.zip); \
	chmod +x $(LOCAL_BIN)packer

install-terraform:
	test -f $(LOCAL_BIN)terraform || \
	(wget -q https://releases.hashicorp.com/terraform/$(TERRAFORM_VERSION)/terraform_$(TERRAFORM_VERSION)_linux_amd64.zip -O /tmp/terraform_$(TERRAFORM_VERSION)_linux_amd64.zip; \
	unzip /tmp/terraform_$(TERRAFORM_VERSION)_linux_amd64.zip -d $(LOCAL_BIN); \
	rm -f /tmp/terraform_$(TERRAFORM_VERSION)_linux_amd64.zip); \
	chmod +x $(LOCAL_BIN)terraform

install-ansible:
	pip3 freeze | grep ansible==$(ANSIBLE_VERSION) || pip3 install ansible kubernetes openshift

install-terraform-plugins:
	test -d $(TERRAFORM_PLUGIN_DIR)/github.com/dmacvicar/libvirt/$(TERRAFORM_LIBVIRT_VERSION)/linux_amd64/ || mkdir -p $(TERRAFORM_PLUGIN_DIR)/github.com/dmacvicar/libvirt/$(TERRAFORM_LIBVIRT_VERSION)/linux_amd64/; \
	test -f $(TERRAFORM_PLUGIN_DIR)/github.com/dmacvicar/libvirt/$(TERRAFORM_LIBVIRT_VERSION)/linux_amd64/terraform-provider-libvirt || \
	(wget https://github.com/dmacvicar/terraform-provider-libvirt/releases/download/v$(TERRAFORM_LIBVIRT_VERSION)/terraform-provider-libvirt-$(TERRAFORM_LIBVIRT_VERSION)+git.1585292411.8cbe9ad0.Ubuntu_18.04.amd64.tar.gz -O /tmp/terraform-provider-libvirt-$(TERRAFORM_LIBVIRT_VERSION).tar.gz && tar xfvz /tmp/terraform-provider-libvirt-$(TERRAFORM_LIBVIRT_VERSION).tar.gz -C $(TERRAFORM_PLUGIN_DIR)/github.com/dmacvicar/libvirt/$(TERRAFORM_LIBVIRT_VERSION)/linux_amd64/ && rm -f /tmp/terraform-provider-libvirt-$(TERRAFORM_LIBVIRT_VERSION).tar.gz)
	test -f $(TERRAFORM_PLUGIN_DIR)/terraform-provisioner-ansible || \
	(wget https://github.com/radekg/terraform-provisioner-ansible/releases/download/v$(TERRAFORM_ANSIBLE_VERSION)/terraform-provisioner-ansible-linux-amd64_v$(TERRAFORM_ANSIBLE_VERSION) -O $(TERRAFORM_PLUGIN_DIR)/terraform-provisioner-ansible && chmod +x $(TERRAFORM_PLUGIN_DIR)/terraform-provisioner-ansible)

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

create-vms:
	cd terraform && terraform init && terraform apply -auto-approve -var "libvirt_uri=$(LIBVIRT_HYPERVISOR_URI)" -var "ssh_key=$(SSH_IDENTITY)" -var-file="cluster$(CLUSTER).tfvars" -state="cluster$(CLUSTER).tfstate"

run-playbook: create-vms
	cd ansible && ansible-playbook -u root -i traefik_inventory site.yml
