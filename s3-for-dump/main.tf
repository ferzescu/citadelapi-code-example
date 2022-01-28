module "s3_bucket_db_dump" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "2.9.0"

  bucket = var.s3_name
  acl    = "private"

  versioning = {
    enabled = true
  }

  tags = {
    Destination = "db_dump"
    Terraform   = "True"
  }

  lifecycle_rule = [
    {
      id      = "dump-cleanup"
      enabled = true
      prefix  = "dumps/"

      tags = {
        rule      = "cleanup"
        autoclean = "true"
      }
      expiration = {
        days = 7
      }
    },
  ]

}

