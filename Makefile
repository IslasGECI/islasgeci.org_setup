all: create_server sleep host_known setup_server

.PHONY: \
	all \
	check \
	clean \
	create_server \
	destroy_server \
	format \
	host_known \
	init \
	setup_server \
	sleep

check:
	cd src && terraform fmt -check

clean:
	rm --force --recursive src/.terraform
	rm --force src/.terraform.lock.hcl
	rm --force src/terraform.tfstate*

create_server: init
	cd src && terraform apply -auto-approve

destroy_server: init
	cd src && terraform destroy -auto-approve

format:
	cd src && terraform fmt

host_known:
	ssh-keyscan "$${INSPECTOR_IP}" > "$${HOME}/.ssh/known_hosts"

init:
	cd src && \
	az login --username $${AZURE_USERNAME} --password $${AZURE_PASSWORD} && \
	terraform init

setup_server:
	ansible-playbook ansible/inspector.yml

sleep:
	@echo "⏳ Waiting to avoid conflicts with APT. 😴 💤 😪"
	sleep 100
