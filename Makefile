all: create_server

.PHONY: \
	all \
	check \
	create_server \
	destroy_server \
	format \
	init

check:
	cd src && terraform fmt -check

create_server: init
	cd src && terraform apply -auto-approve

destroy_server: init
	cd src && terraform destroy -auto-approve

clean:
	rm --force --recursive src/.terraform
	rm --force src/.terraform.lock.hcl
	rm --force src/terraform.tfstate*

format:
	cd src && terraform fmt

init:
	cd src && \
	az login --username $${AZURE_USERNAME} --password $${AZURE_PASSWORD} && \
	terraform init
