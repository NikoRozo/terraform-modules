#--------------------------------------------------------------
# Estos modulos crea los recursos necesarios para el alb
#--------------------------------------------------------------

variable "name"                { default = "lb" }
variable "tags"                { }
variable "vpc_id"              { }
variable "private_ids"         { }
variable "tipo"                { }

resource "aws_lb" "lb" {
  name               = var.name
  internal           = true
  load_balancer_type = var.tipo
  subnets            = var.private_ids
  
  enable_cross_zone_load_balancing = true

  tags  = merge(
    var.tags,
    { Name = var.name },
  )
}

output "lb_name" { value = "${aws_lb.lb.name}" }
output "lb_arn" { value = "${aws_lb.lb.arn}" }
output "lb_dns_name" { value = "${aws_lb.lb.dns_name}" }