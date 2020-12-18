#--------------------------------------------------------------
# Modulo que crea todos los recursos necesarios para Route 53
#--------------------------------------------------------------

variable "zone" { }
variable "domain"  { }

data "aws_route53_zone" "main" {
  name = var.zone
}

resource "aws_api_gateway_domain_name" "main" {
  domain_name              = var.domain
  #regional_certificate_arn = aws_acm_certificate.main.arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_route53_record" "main" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = aws_api_gateway_domain_name.main.domain_name
  type    = "CNAME"
  records = [aws_api_gateway_domain_name.main.regional_domain_name]
  ttl     = "60"
}

output "domain_name" { value = "${aws_api_gateway_domain_name.main.domain_name}" }