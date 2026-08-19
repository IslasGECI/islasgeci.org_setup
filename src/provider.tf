terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  backend "local" {
    path = "/workdir/state/terraform.tfstate"
  }
}

provider "aws" {
  region = "us-east-1"
}
