terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.60.0"
    }
  }
}

provider "aws" {
  region = var.region
}

terraform {
  backend "remote" {
    organization = "contoso"

    workspaces {
      name = var.env_name
    }
  }
}
