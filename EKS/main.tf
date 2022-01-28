locals {
  name = "eks-${var.env_name}"
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "17.24.0"

  cluster_version = "1.21"
  cluster_name    = local.name
  vpc_id          = module.vpc.vpc_id
  subnets         = [module.vpc.private_subnets[0], module.vpc.public_subnets[1]]
  enable_irsa     = true

  node_groups_defaults = {
    ami_type  = "AL2_x86_64"
    disk_size = 20
  }

  node_groups = {
    ng = {
      desired_capacity = 3
      max_capacity     = 5
      min_capacity     = 2

      instance_types = ["t2.large"]
      k8s_labels = {
        "Terraform" = "True"
      }
      additional_tags = {
        "k8s.io/cluster-autoscaler/enabled"       = "True"
        "k8s.io/cluster-autoscaler/${local.name}" = "owned"
        "Name"                                    = "eks-worker-node-${random_string.suffix.result}"
      }
      update_config = {
        max_unavailable_percentage = 50 # or set `max_unavailable`
      }
    }
  }
  map_users = [
    {
      userarn  = "arn:aws:iam::692995198865:user/ivan"
      username = "ivan"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::692995198865:user/ai"
      username = "ai"
      groups   = ["staff"]
    },
    {
      userarn  = "arn:aws:iam::692995198865:user/artamonychev"
      username = "artamonychev"
      groups   = ["staff"]
    },
    {
      userarn  = "arn:aws:iam::692995198865:user/serhiy"
      username = "serhiy"
      groups   = ["staff"]
    },
  ]
  tags = {
    "k8s.io/cluster-autoscaler/enabled"       = "True"
    "k8s.io/cluster-autoscaler/${local.name}" = "owned"
  }
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}
