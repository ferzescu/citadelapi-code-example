terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.72.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 1.11.1"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 1.4"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.1"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}


terraform {
  backend "remote" {
    organization = "condoso"

    workspaces {
      name = "eks"
    }
  }
}
