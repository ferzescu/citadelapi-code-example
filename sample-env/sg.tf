#EC2
module "security-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = var.env_name
  description = "Security group for EC2 instance"
  vpc_id      = data.aws_vpc.vpc.id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  egress_rules        = ["all-all"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 2
      protocol    = "tcp"
      description = "SSH"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

#ALB
module "security_group_alb" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "alb-sg-${var.env_name}"
  description = "Security group for usage with ALB-${var.env_name}"
  vpc_id      = data.aws_vpc.alb.id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  egress_rules        = ["all-all"]
}


data "aws_subnet_ids" "subnet" {
  vpc_id = data.aws_vpc.vpc.id
}


data "aws_vpc" "vpc" {
  default = true
}