#--------------------------------------------------------------
# Estos modulos crea los recursos necesarios el API Gateway
#--------------------------------------------------------------

variable "domain"      { default = "acm" }
variable "tags"        { }

resource "aws_acm_certificate" "main" {
  domain_name       = var.domain
  validation_method = "DNS"

  tags  = merge(
    var.tags,
    { domain_name = "${var.domain}" },
  )

  lifecycle {
    create_before_destroy = true
  }
}