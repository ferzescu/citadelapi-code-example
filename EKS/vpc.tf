module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name                 = local.name
  cidr                 = var.cidr_block
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = [for index in range(1,4): cidrsubnet(var.cidr_block, 8, index)]                                                       
  public_subnets       = [for index in range(4,7): cidrsubnet(var.cidr_block, 8, index)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/elb"              = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/internal-elb"     = "1"
  }

  tags = {
    Terraform = "True"
  }
}

data "aws_availability_zones" "available" {
}
