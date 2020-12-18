#--------------------------------------------------------------
# Modulo que crea todos los recursos necesarios para una VPC
#--------------------------------------------------------------

variable "name" { default = "vpc" }
variable "tags" { }
variable "cidr" { }

resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags  = merge(
    var.tags,
    { Name = "${var.name}" },
  )

  lifecycle { create_before_destroy = true }
}

output "vpc_id"   { value = "${aws_vpc.vpc.id}" }
output "vpc_cidr" { value = "${aws_vpc.vpc.cidr_block}" }