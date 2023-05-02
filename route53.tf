# Create DNS record for CloudFront distribution
resource "aws_route53_record" "static_website_dns" {
  zone_id = data.aws_route53_zone.this.id
  name    = var.domain
  type    = "A"

  alias {
    name                   = module.cloudfront.cloudfront_distribution_domain_name
    zone_id                = module.cloudfront.cloudfront_distribution_hosted_zone_id
    evaluate_target_health = false
  }
}
