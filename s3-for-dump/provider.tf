terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.60.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "remote" {
    organization = "bssreader"

    workspaces {
      name = "s3-db-dump"
    }
  }
}
