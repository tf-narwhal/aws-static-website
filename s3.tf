# Create an S3 bucket for the static website
module "s3_static_website" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.0"

  bucket        = "${var.domain}-${module.tools.account_id}"
  force_destroy = true
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



