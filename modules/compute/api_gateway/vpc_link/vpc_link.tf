#--------------------------------------------------------------
# Estos modulos crea los recursos necesarios el API Gateway
#--------------------------------------------------------------

variable "name"        { default = "vpc" }
variable "tags"        { }
variable "target_arns" { }

resource "aws_api_gateway_vpc_link" "main" {
  name        = var.name
  description = "permite que API Gateway Publico se pueda cominicar con el Backend en Red Privada del proyecto ${var.name}"
  target_arns = var.target_arns
  
  tags  = merge(
    var.tags,
    { Name = "${var.name}" },
  )

  lifecycle {
    create_before_destroy = true
  }
}

output "vpc_link" { value = "${aws_api_gateway_vpc_link.main.id}" }