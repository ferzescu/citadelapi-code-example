variable "region" {
  type    = string
  default = "us-east-1"
}
variable "instance-type" {
  default = "t2.large"
}
variable "ssh-key" {
  default = "condoso-admin"
}

variable "env_name" {
  default = "develop"
}

variable "ec2_amount" {
  default = 3
  type = number
}
