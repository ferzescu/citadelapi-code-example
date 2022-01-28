

variable env_name {
    type = string
    default = "develop"
}

variable region {
    type = string
    default = "us-west-1"
}

variable cidr_block {
  default     = "10.1.0.0/16"
  description = "VPC ip CIDR"
}
