# Create an S3 bucket for the static website
module "s3_static_website" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.0"

  bucket        = "${var.domain}-${module.tools.account_id}"
  force_destroy = true

  control_object_ownership  = true
  object_ownership          = "BucketOwnerPreferred"
  #acl                       = "public-read"

  # S3 bucket-level Public Access Block configuration (by default now AWS has made this default as true for S3 bucket-level block public access)
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

  logging = {
    target_bucket = module.log_bucket.s3_bucket_id
    target_prefix = "${var.domain}/"
  }

  # versioning = {
  #   status     = true
  # }

  website = {
    index_document = "index.html"
    error_document = var.error_document
  }
}

module "log_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.0"

  bucket        = "${var.domain}-logs-${module.tools.account_id}"
  force_destroy = true

  control_object_ownership = true

  attach_elb_log_delivery_policy        = true
  attach_lb_log_delivery_policy         = true
  attach_access_log_delivery_policy     = true
  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true

  access_log_delivery_policy_source_accounts = [module.tools.account_id]
  access_log_delivery_policy_source_buckets  = ["arn:aws:s3:::${var.domain}-${module.tools.account_id}"]
}

# Set the S3 bucket policy to allow access from the CloudFront distribution
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = module.s3_static_website.s3_bucket_id
  policy = data.aws_iam_policy_document.bucket_policy.json
}

data "aws_iam_policy_document" "bucket_policy" {
  dynamic "statement" {
    for_each = concat(
      [{
        sid = "AllowCloudFrontServicePrincipal"
        principals = {
          type        = "Service"
          identifiers = ["cloudfront.amazonaws.com"]
        }
        actions = ["s3:GetObject"]
        resources = ["${module.s3_static_website.s3_bucket_arn}/*", "${module.s3_static_website.s3_bucket_arn}"]
        condition = [{
          test     = "StringEquals"
          variable = "AWS:SourceArn"
          values   = [module.cloudfront.cloudfront_distribution_arn]
        }]
      }],
      [for arn in var.role_arns : {
        sid = "AllowRoleAccess"
        principals = {
          type        = "AWS"
          identifiers = [arn]
        }
        actions   = ["s3:*"]
        resources = ["${module.s3_static_website.s3_bucket_arn}/*", "${module.s3_static_website.s3_bucket_arn}"]
        condition = []
      }]
    )

    content {
      sid       = statement.value.sid
      effect    = "Allow"
      actions   = statement.value.actions
      resources = statement.value.resources

      principals {
        type        = statement.value.principals.type
        identifiers = statement.value.principals.identifiers
      }

      dynamic "condition" {
        for_each = statement.value.condition
        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }
}



