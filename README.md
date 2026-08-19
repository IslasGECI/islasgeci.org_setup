# islasgeci.org Infrastructure

Infrastructure as Code for provisioning and configuring the [islasgeci.org](https://islasgeci.org) web server on AWS.

## Overview

- **Terraform** provisions the AWS infrastructure (VPC, subnet, security group, EC2 instance, EIP)
- **Ansible** configures the server (installs Docker, Git, Make; deploys the website container)
- **Docker** runs the `islasgeci/islasgeci.org` container with mounted secrets

## Prerequisites

- AWS credentials configured (`aws configure`)
- SSH key pair at `~/.ssh/id_rsa.pub`
- Docker and Docker Compose (for containerized setup)

## Usage

Full setup (create server + configure + deploy):

```bash
make
```

Or run individual steps:

| Command | Description |
|---------|-------------|
| `make create_server` | Provision AWS infrastructure with Terraform |
| `make host_known` | Add the server IP to `~/.ssh/known_hosts` |
| `make setup_server` | Configure the server with Ansible |
| `make destroy_server` | Destroy the EC2 instance |
| `make format` | Format Terraform files |
| `make check` | Check Terraform formatting |
| `make clean` | Remove Terraform state files |

## Architecture

```
AWS (us-east-1)
├── VPC (10.0.0.0/16)
│   ├── Subnet (10.0.2.0/24)
│   │   ├── Network Interface
│   │   └── EC2 Instance (Ubuntu 24.04)
│   │       └── Docker: islasgeci.org container
│   └── Internet Gateway
├── Elastic IP
└── Security Group
    ├── Inbound: SSH (22), HTTP (80), ports 100/200/300/500
    └── Outbound: DNS, HTTP, HTTPS, NTP
```
