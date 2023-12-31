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
	cd src && terraform destroy -auto-approve -target="azurerm_linux_virtual_machine.webserver"

format:
	cd src && terraform fmt

host_known:
	cd src && \
	ssh-keyscan "$$(terraform output -raw webserver_ip)" > "$${HOME}/.ssh/known_hosts"

init:
	cd src && \
	az login --username $${AZURE_USERNAME} --password $${AZURE_PASSWORD} && \
	terraform init

setup_server:
	cd src && \
	export WEBSERVER_IP=$$(terraform output -raw webserver_ip) && \
	ansible-playbook /workdir/ansible/webserver.yml

sleep:
	@echo "⏳ Idly waiting to avoid conflicts with APT. 😴 💤 😪"
	sleep 100
