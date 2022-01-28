module "ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 2.0"

  name           = var.env_name
  instance_count = var.ec2_amount

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance-type
  key_name               = var.ssh-key
  monitoring             = true
  vpc_security_group_ids = [module.security-group-stage.security_group_id]
  subnet_id              = tolist(data.aws_subnet_ids.subnet.ids)[0]

  tags = {
    Terraform   = "true"
    Environment = var.env_name
  }
}


resource "aws_eip" "eip" {
  count    = module.ec2.instance_count
  vpc      = true
  instance = element(module.ec2.id, count.index)
  tags = {
    Terraform   = "true"
    Environment = var.env_name
  }
}


data "aws_ami" "ubuntu" {

  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

