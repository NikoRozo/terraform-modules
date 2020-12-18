#--------------------------------------------------------------
# Este modulo crea los recursos necesarios para una NAT
#--------------------------------------------------------------

variable "name"              { default = "nat" }
variable "tags"              { }
variable "one_nat"           { type = bool }
variable "azs"               { }
variable "public_subnet_ids" { }

resource "aws_eip" "nat" {
  vpc   = true

  tags  = merge(
    var.tags,
    { Name = "${var.name}.${element(var.azs, count.index)}" },
  )

  count = var.one_nat ? 1 : length(var.azs) # One_nat is true, create one nat for all subnets

  lifecycle { create_before_destroy = true }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(var.public_subnet_ids, count.index)
  tags  = merge(
    var.tags,
    { Name = "${var.name}.${element(var.azs, count.index)}" },
  )

  count = var.one_nat ? 1 : length(var.azs) # One_nat is true, create one nat for all subnets

  lifecycle { create_before_destroy = true }
}

output "nat_gateway_ids" { value = "${aws_nat_gateway.nat.*.id}" }