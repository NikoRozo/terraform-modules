#--------------------------------------------------------------
# Este modulo crea los recursos necesarios para crear Security Group
#--------------------------------------------------------------

variable "name"              { default = "nat" }
variable "tags"              { }
variable "vpc_id"            { }
variable "ingress_rule"      { }
variable "cidrs"             { }

resource "aws_security_group" "sg" {
  name = "${var.name}-sg"
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rule
    content {
        from_port   = ingress.value.from_port
        to_port     = ingress.value.to_port
        protocol    = ingress.value.protocol
        cidr_blocks = ingress.value.cidr_blocks
    }
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "tcp"
    cidr_blocks = var.cidrs
  }

  egress {
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags  = merge(
    var.tags,
    { Name = "${var.name}-sg" },
  )
}

output "sg_id" { value = "${aws_security_group.sg.*.id}" }