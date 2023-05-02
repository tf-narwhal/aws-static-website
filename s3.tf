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
  policy = jsonencode({
    "Version": "2008-10-17",
    "Id": "PolicyForCloudFrontPrivateContent",
    "Statement": [
      {
        "Sid": "AllowCloudFrontServicePrincipal",
        "Effect": "Allow",
        "Principal": {
          "Service": "cloudfront.amazonaws.com"
        },
        "Action": "s3:GetObject",
        "Resource": [
          "${module.s3_static_website.s3_bucket_arn}/*"
        ],
        "Condition": {
          "StringEquals": {
            "AWS:SourceArn": "${module.cloudfront.cloudfront_distribution_arn}"
          }
        }
      }
    ]
  })
}
