#--------------------------------------------------------------
# Estos modulos crea los recursos necesarios para la VPC
#--------------------------------------------------------------

variable "name"                  { }
variable "tags"                  { }
variable "vpc_cidr"              { }
variable "azs"                   { }
variable "private_subnets"       { }
variable "public_subnets"        { }
variable "one_nat"               { }

module "vpc" {
  source = "./vpc"

  name = "${var.name}-vpc"
  tags = var.tags
  cidr = var.vpc_cidr
}

module "public_subnet" {
  source = "./public_subnet"

  name   = "${var.name}-public"
  tags   = var.tags
  vpc_id = "${module.vpc.vpc_id}"
  cidrs  = var.public_subnets
  azs    = var.azs
}

module "nat" {
  source = "./nat"

  name              = "${var.name}-nat"
  azs               = var.azs
  public_subnet_ids = "${module.public_subnet.subnet_ids}"
  tags = var.tags
  one_nat           = var.one_nat
}

module "private_subnet" {
  source = "./private_subnet"

  name   = "${var.name}-private"
  tags = var.tags
  vpc_id = "${module.vpc.vpc_id}"
  cidrs  = var.private_subnets
  azs    = var.azs

  nat_gateway_ids = "${module.nat.nat_gateway_ids}"
}

resource "aws_network_acl" "acl" {
  vpc_id     = module.vpc.vpc_id
  subnet_ids = setunion(module.public_subnet.subnet_ids, module.private_subnet.subnet_ids)
  #subnet_ids = flatten([concat([split(",", module.public_subnet.subnet_ids)], [split(",", module.private_subnet.subnet_ids)])])

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags  = merge(
    var.tags,
    { Name = "${var.name}-all" },
  )

}

# VPC
output "vpc_id"   { value = "${module.vpc.vpc_id}" }
output "vpc_cidr" { value = "${module.vpc.vpc_cidr}" }

# Subnets
output "public_subnet_ids"  { value = "${module.public_subnet.subnet_ids}" }
output "private_subnet_ids" { value = "${module.private_subnet.subnet_ids}" }
output "public_subnet_cidr_block"  { value = "${module.public_subnet.cidr_block}" }
output "private_subnet_cidr_block" { value = "${module.private_subnet.cidr_block}" }

# NAT
output "nat_gateway_ids" { value = "${module.nat.nat_gateway_ids}" }

# Route Table
output "private_route_table_ids" { value = "${module.private_subnet.route_ids}" }