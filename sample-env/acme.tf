module "acm_request_certificate" {
  source = "cloudposse/acm-request-certificate/aws"

  # version = "x.x.x"
  domain_name                       = "contoso.com"
  subject_alternative_names         = ["*.contoso.com"]
  process_domain_validation_options = true
  ttl                               = "300"
  tags = {
    Environment = "${var.env_name}"
  }
}
