# Create an ACM certificate for the domain
module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name               = var.domain
  subject_alternative_names = var.additional_aliases
  zone_id                   = data.aws_route53_zone.this.id
}
