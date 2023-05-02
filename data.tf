# Get the Route53 zone for the domain
data "aws_route53_zone" "this" {
  name = var.domain
}
