# Create CloudFront distribution module
module "cloudfront" {
  source = "terraform-aws-modules/cloudfront/aws"

  # Set aliases for the CloudFront distribution
  aliases = concat(["${var.domain}"], var.additional_aliases)

  # Set comment, HTTP version, IPv6 support, price class, and retention policy for the CloudFront distribution
  comment             = var.description
  enabled             = true
  http_version        = "http2and3"
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  wait_for_deployment = false
  #default_root_object = "index.html"

  # Enable CloudWatch metrics for the CloudFront distribution
  create_monitoring_subscription = true

  # Create an origin access identity for the S3 bucket
  create_origin_access_identity = true
  origin_access_identities = {
    s3_bucket_one = "${var.project_name} can access"
  }

  # # Create an origin access control for the CloudFront distribution
  # create_origin_access_control = true
  # origin_access_control = {
  #   static_website_root = {
  #     description      = "CloudFront access to S3"
  #     origin_type      = "s3"
  #     signing_behavior = "always"
  #     signing_protocol = "sigv4"
  #   }
  # }

  # Set the origin for the CloudFront distribution
  origin = {
    static_website_root = {
      domain_name = module.s3_static_website.s3_bucket_website_endpoint
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
      }

      origin_shield = {
        enabled              = true
        origin_shield_region = "us-east-1"
      }
    }
  }

  # Set the default cache behavior for the CloudFront distribution
  default_cache_behavior = {
    target_origin_id       = "static_website_root"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    query_string           = true
  }

  # Set the SSL certificate for the CloudFront distribution
  viewer_certificate = {
    acm_certificate_arn = module.acm.acm_certificate_arn
    ssl_support_method  = "sni-only"
  }
}
