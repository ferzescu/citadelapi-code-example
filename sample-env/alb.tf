module "alb" {
  depends_on = [module.ec2]
  source     = "terraform-aws-modules/alb/aws"
  version    = "~> 6.0"

  name = "${var.env_name}-alb"

  load_balancer_type = "application"

  vpc_id          = data.aws_vpc.alb.id
  subnets         = data.aws_subnet_ids.alb.ids
  security_groups = [module.security_group_alb.security_group_id]

  target_groups = [
    {
      name_prefix      = "${var.env_name}-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      stickiness = {
        enabled         = true
        type            = "lb_cookie"
        cookie_duration = "86400"

      }
      targets = [
        {
          target_id   = module.ec2.id[0]
          port        = 80
          action_type = "redirect"
          redirect = {
            port        = "443"
            protocol    = "HTTPS"
            status_code = "HTTP_301"
          }
        }
      ]
    }
  ]


  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
      action_type        = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]
  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = module.acm_request_certificate.arn
      target_group_index = 0
    }
  ]

  tags = {
    Environment = var.env_name
  }
}

data "aws_subnet_ids" "alb" {
  vpc_id = data.aws_vpc.alb.id
}
data "aws_vpc" "alb" {
  default = true
