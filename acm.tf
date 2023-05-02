# Create an ACM certificate for the domain
module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name               = var.domain
  zone_id                   = data.aws_route53_zone.this.id
}
