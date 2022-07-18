.PHONY: help all check-env my-linux-env create-env install-packer install-terraform install-ansible install-terraform-plugins image build-image upload-image import-kube-nodes create-vms run-playbook destroy
.DEFAULT_GOAL := all

LOCAL_BIN := ~/.local/bin/
PACKER_VERSION := 1.8.2
TERRAFORM_PLUGIN_DIR := ~/.terraform.d/plugins
TERRAFORM_VERSION := 1.2.3
TERRAFORM_LIBVIRT_FULL_VERSION := 0.6.14_linux_amd64
TERRAFORM_LIBVIRT_VERSION := 0.6.14#if you change that, change also terraform/traefik.tf
TERRAFORM_ANSIBLE_VERSION := 2.5.0
ANSIBLE_VERSION := 2.10.8
LIBVIRT_HYPERVISOR_URI := "qemu:///system"
LIBVIRT_TEMPLATES_IMAGES_POOL := "templates"
LIBVIRT_TEMPLATES_IMAGES_POOL_DIR := "/var/lib/libvirt/images/templates"
LIBVIRT_IMAGE_NAME := "debian11-traefik.qcow2"
ROOT_PASSWORD := "traefik"
CLUSTER := 1
TRAEFIKEE_LICENSE := "N/A"
$(eval SSH_IDENTITY=$(shell find ~/.ssh/ -name 'id_*' -not -name '*.pub' | head -n 1))
#SSH_IDENTITY := "~/.ssh/id_rsa_unencrypted"

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

all:

check-env: ## Check environment.
	@(which unzip 2>&1 > /dev/null) || (echo "unzip is not in your PATH" && exit 1)
	@(which curl 2>&1 > /dev/null) || (echo "curl is not in your PATH" && exit 1)
	@(which virsh 2>&1 > /dev/null) || (echo "virsh is not in your PATH" && exit 1)
	@(terraform version 2>&1 | grep -E 'v0.1([4-9].[0-9]|3.[3-9])' > /dev/null) || (echo "terraform is not in your PATH or is not up to date" && exit 1)
	@(packer version 2>&1 | grep -E 'v1.([7-9].[0-9]|6.[2-9])' > /dev/null) || (echo "packer is not in your PATH or is not up to date" && exit 1)
	@(ansible --version | head -n 1 | grep -E '(2.9.(1[3-9]|[2-9][0-9])|[3-9].[0-9].[0-9])' > /dev/null) || (echo "ansible is not in your PATH or is not up to date" && exit 1)
	@(id -u | id -nGz | grep -qzxF libvirt) || (echo "you are not in the libvirt group" && exit 1)
	@echo "You're ready to play!"

my-linux-env: create-env install-packer install-terraform install-terraform-plugins install-ansible ## Install environment.

create-env: ## Create directories and set env variables for binary dependencies.
	test -d $(LOCAL_BIN)|| mkdir -p $(LOCAL_BIN)
	echo ${PATH} | grep $(LOCAL_BIN) || (echo 'export PATH=$$PATH:~/.local/bin/' >> ~/.bashrc; . ~/.bashrc)

install-packer: ## Install Packer.
	test -f $(LOCAL_BIN)packer || \
	(curl https://releases.hashicorp.com/packer/$(PACKER_VERSION)/packer_$(PACKER_VERSION)_linux_amd64.zip -o /tmp/packer_$(PACKER_VERSION)_linux_amd64.zip; \
	unzip /tmp/packer_$(PACKER_VERSION)_linux_amd64.zip -d $(LOCAL_BIN); \
	rm -f /tmp/packer_$(PACKER_VERSION)_linux_amd64.zip); \
	chmod +x $(LOCAL_BIN)packer

install-terraform: ## Install Terraform.
	test -f $(LOCAL_BIN)terraform || \
	(curl -q https://releases.hashicorp.com/terraform/$(TERRAFORM_VERSION)/terraform_$(TERRAFORM_VERSION)_linux_amd64.zip -o /tmp/terraform_$(TERRAFORM_VERSION)_linux_amd64.zip; \
	unzip /tmp/terraform_$(TERRAFORM_VERSION)_linux_amd64.zip -d $(LOCAL_BIN); \
	rm -f /tmp/terraform_$(TERRAFORM_VERSION)_linux_amd64.zip); \
	chmod +x $(LOCAL_BIN)terraform

install-ansible: ## Install Ansible with pip.
	pip3 freeze | grep ansible==$(ANSIBLE_VERSION) || pip3 install ansible

install-terraform-plugins:
	test -d $(TERRAFORM_PLUGIN_DIR)/github.com/dmacvicar/libvirt/$(TERRAFORM_LIBVIRT_VERSION)/linux_amd64/ || mkdir -p $(TERRAFORM_PLUGIN_DIR)/github.com/dmacvicar/libvirt/$(TERRAFORM_LIBVIRT_VERSION)/linux_amd64/; \
	test -f $(TERRAFORM_PLUGIN_DIR)/github.com/dmacvicar/libvirt/$(TERRAFORM_LIBVIRT_VERSION)/linux_amd64/terraform-provider-libvirt || \
	(curl -L https://github.com/dmacvicar/terraform-provider-libvirt/releases/download/v$(TERRAFORM_LIBVIRT_VERSION)/terraform-provider-libvirt_$(TERRAFORM_LIBVIRT_FULL_VERSION).zip -o /tmp/terraform-provider-libvirt-$(TERRAFORM_LIBVIRT_VERSION).zip && mkdir -p $(TERRAFORM_PLUGIN_DIR)/github.com/dmacvicar/libvirt/$(TERRAFORM_LIBVIRT_VERSION)/linux_amd64 && unzip -j /tmp/terraform-provider-libvirt-$(TERRAFORM_LIBVIRT_VERSION).zip terraform-provider-libvirt_v$(TERRAFORM_LIBVIRT_VERSION) -d $(TERRAFORM_PLUGIN_DIR)/github.com/dmacvicar/libvirt/$(TERRAFORM_LIBVIRT_VERSION)/linux_amd64/ && mv $(TERRAFORM_PLUGIN_DIR)/github.com/dmacvicar/libvirt/$(TERRAFORM_LIBVIRT_VERSION)/linux_amd64/terraform-provider-libvirt_v$(TERRAFORM_LIBVIRT_VERSION) $(TERRAFORM_PLUGIN_DIR)/github.com/dmacvicar/libvirt/$(TERRAFORM_LIBVIRT_VERSION)/linux_amd64/terraform-provider-libvirt && rm -f /tmp/terraform-provider-libvirt-$(TERRAFORM_LIBVIRT_VERSION).zip); \
	test -f $(TERRAFORM_PLUGIN_DIR)/terraform-provisioner-ansible || \
	(curl -L https://github.com/radekg/terraform-provisioner-ansible/releases/download/v$(TERRAFORM_ANSIBLE_VERSION)/terraform-provisioner-ansible-linux-amd64_v$(TERRAFORM_ANSIBLE_VERSION) -o $(TERRAFORM_PLUGIN_DIR)/terraform-provisioner-ansible && chmod +x $(TERRAFORM_PLUGIN_DIR)/terraform-provisioner-ansible)

qemu-security:
	sed -i 's/\#user = \"root\"/user = \"root\"/g' /etc/libvirt/qemu.conf
	sed -i 's/\#group = \"root\"/group = \"root\"/g' /etc/libvirt/qemu.conf
	sed -i 's/\#security_driver = \"selinux\"/security_driver = \"none\"/g' /etc/libvirt/qemu.conf
	systemctl restart libvirtd

image: build-image upload-image ## Build image with Packer and upload it to libvirt with virsh.

build-image: ## Build image with Packer.
	rm -rf  packer/output
	$(eval CRYPTED_PASSWORD = $$(shell openssl passwd -6 "$(ROOT_PASSWORD)"))
	sed -r 's@^(d-i passwd\/root-password-crypted password).*@\1 $(CRYPTED_PASSWORD)@g' packer/preseed/debian11.txt > packer/preseed/debian11.txt.password
	cd packer && ROOT_PASSWORD=$(ROOT_PASSWORD) SSH_PUB_KEY="$(shell cat $(SSH_IDENTITY).pub)" packer build base.json

upload-image: ## Upload image to libvirt with virsh.
	$(eval  size = $(shell stat -Lc%s packer/output/debian11))
	test -d $(LIBVIRT_TEMPLATES_IMAGES_POOL_DIR) || mkdir $(LIBVIRT_TEMPLATES_IMAGES_POOL_DIR)
	virsh -c $(LIBVIRT_HYPERVISOR_URI) pool-create-as $(LIBVIRT_TEMPLATES_IMAGES_POOL) dir --target $(LIBVIRT_TEMPLATES_IMAGES_POOL_DIR) 2>/dev/null || echo "did not create pool"
	virsh -c $(LIBVIRT_HYPERVISOR_URI) pool-start $(LIBVIRT_TEMPLATES_IMAGES_POOL) 2>/dev/null || echo "did not enable pool"
	test ! -e $(LIBVIRT_TEMPLATES_IMAGES_POOL_DIR)/$(LIBVIRT_IMAGE_NAME) || virsh -c $(LIBVIRT_HYPERVISOR_URI) vol-delete --pool $(LIBVIRT_TEMPLATES_IMAGES_POOL) $(LIBVIRT_IMAGE_NAME)
	virsh -c $(LIBVIRT_HYPERVISOR_URI) vol-create-as $(LIBVIRT_TEMPLATES_IMAGES_POOL) $(LIBVIRT_IMAGE_NAME) $(size) --format qcow2 && \
	virsh -c $(LIBVIRT_HYPERVISOR_URI) vol-upload --pool $(LIBVIRT_TEMPLATES_IMAGES_POOL) $(LIBVIRT_IMAGE_NAME) packer/output/debian11

import-kube-nodes: ## Use some Terraform resources from step 1 in step 2, and some resources from step 2 in step 3.
	[ $(CLUSTER) -eq 2 ] && { \
	cd terraform ; \
	[ -f cluster1.tfstate ] && ! [ -f cluster2.tfstate ] && { \
	cp cluster1.tfstate cluster1.tfstate.copy; \
	terraform state mv -state=cluster1.tfstate.copy -state-out=cluster2.tfstate libvirt_network.network libvirt_network.network; \
	terraform state mv -state=cluster1.tfstate.copy -state-out=cluster2.tfstate libvirt_pool.images libvirt_pool.images; \
	rm -f cluster1.tfstate.copy ; \
	} \
	} || echo "not importing"
	[ $(CLUSTER) -eq 3 ] && { \
	cd terraform ; \
	[ -f cluster2.tfstate ] && ! [ -f cluster3.tfstate ] && { \
	cp cluster2.tfstate cluster2.tfstate.copy; \
	for i in 3 4 5 ; do \
		terraform state mv -state=cluster2.tfstate.copy -state-out=cluster3.tfstate libvirt_domain.vm[$$i] libvirt_domain.vm[$$((i+1))]; \
	done; \
	terraform state mv -state=cluster2.tfstate.copy -state-out=cluster3.tfstate libvirt_network.network libvirt_network.network; \
	terraform state mv -state=cluster2.tfstate.copy -state-out=cluster3.tfstate libvirt_pool.images libvirt_pool.images; \
	rm -f cluster2.tfstate.copy ; \
	} \
	} || echo "not importing"

# If there is a problem of rights when the VM is starting, you have to follow
# https://github.com/dmacvicar/terraform-provider-libvirt/commit/22f096d94f2480a678c388cb2d8eff91425ed13d
create-vms: import-kube-nodes ## Apply Terraform.
	cd terraform && terraform init && terraform apply -auto-approve -var "libvirt_uri=$(LIBVIRT_HYPERVISOR_URI)" -var "ssh_key=$(SSH_IDENTITY)" -var "templates_pool=$(LIBVIRT_TEMPLATES_IMAGES_POOL)" -var "template_img=$(LIBVIRT_IMAGE_NAME)" -var-file="cluster$(CLUSTER).tfvars" -state="cluster$(CLUSTER).tfstate"

run-playbook: create-vms ## Apply Ansible playbook.
	cd ansible && ansible-playbook -u root -i traefik_inventory -e "traefikee_license_key=$(TRAEFIKEE_LICENSE_KEY)" site.yml

destroy: ## Destroy Terraform resources.
	cd terraform && terraform destroy -auto-approve -state="cluster$(CLUSTER).tfstate"