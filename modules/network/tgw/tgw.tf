#--------------------------------------------------------------
# Estos modulos crea los recursos necesarios para asociar el TGW a una VPC
#--------------------------------------------------------------

variable "subnet_ids"           { }
variable "transit_gateway_id"   { }
variable "vpc_id"               { }
variable "route_table_id"       { }
variable "route_trasit_gateway" { }

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw" {
  subnet_ids         = var.subnet_ids
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = var.vpc_id
}

resource "aws_route" "route_transit" {
  count                     = length(var.route_trasit_gateway)
  route_table_id            = element(var.route_table_id, lookup(element(var.route_trasit_gateway, count.index), "route_table_id"))
  destination_cidr_block    = lookup(element(var.route_trasit_gateway, count.index), "cidr_block")
  transit_gateway_id        = var.transit_gateway_id

  lifecycle { create_before_destroy = true }
}

output "id" { value = "${aws_ec2_transit_gateway_vpc_attachment.tgw.id}" }