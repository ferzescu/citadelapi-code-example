module "cdn" {
  source  = "cloudposse/cloudfront-s3-cdn/aws"
  version = "0.74.0"

  name                                = var.env_name
  aliases                             = ["${var.env_name}.contoso.com", "contoso.com", "i.contoso.com"]
  dns_alias_enabled                   = true
  parent_zone_name                    = "contoso.com"
  versioning_enabled                  = false
  acm_certificate_arn                 = module.acm_request_certificate.arn
  origin_force_destroy                = true
  compress                            = true
  website_enabled                     = true
  error_document                      = "index.html"
  cloudfront_access_log_create_bucket = false
  cloudfront_access_logging_enabled   = false
  override_origin_bucket_policy       = false
  cors_allowed_origins                = ["api-${var.env_name}.contoso.com", "contoso.com"]
  allow_ssl_requests_only             = false
  custom_origins = [{
    custom_headers = []
    custom_origin_config = {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "https-only"
      origin_ssl_protocols     = ["TLSv1", "TLSv1.1", "TLSv1.2"]
      origin_keepalive_timeout = 5
      origin_read_timeout      = 30
    }
    domain_name = "api-${var.env_name}.contoso.com"
    origin_id   = "crawler"
    origin_path = ""
  }]

  ordered_cache = [
    {
      path_pattern                = "/crawler*"
      allowed_methods             = ["GET", "HEAD", "OPTIONS", "PUT", "DELETE", "POST", "PATCH"]
      cached_methods              = ["GET", "HEAD", "OPTIONS"]
      target_origin_id            = local.s3_origin_id
      compress                    = true
      viewer_protocol_policy      = "redirect-to-https"
      min_ttl                     = 0
      max_ttl                     = 31536000
      default_ttl                 = 86400
      forward_query_string        = false
      forward_header_values       = ["*"]
      forward_cookies             = "all"
      lambda_function_association = []
      function_association        = []
      trusted_signers             = []
      trusted_key_groups          = []
      origin_request_policy_id    = ""
      cache_policy_id             = ""
    }
  ]
}

locals {
  s3_origin_id = "crawler"
}
