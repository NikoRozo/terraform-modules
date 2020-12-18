#--------------------------------------------------------------
# Estos modulos crea los recursos necesarios para el ECS Service
#--------------------------------------------------------------

variable "name"               { default = "service" }
variable "tags"               { }
variable "cluster_id"         { }
variable "lb_arn"             { }
variable "containers"         { }
variable "tg_names"           { }
variable "task_family"        { }
variable "task_revison"       { }
variable "vpc_id"             { }
variable "subnets"            { }
variable "security_group"     { }

resource "aws_lb_target_group" "target_group" {
  count    = length(var.tg_names) 
  name     = lookup(element(var.tg_names, count.index), "tg_name")
  port     = 80
  protocol = "TCP"
  vpc_id   = var.vpc_id
  target_type = "ip"
    
  health_check {
    protocol = "TCP"
    healthy_threshold = 10
    unhealthy_threshold = 10
  }
}

resource "aws_lb_listener" "lb-listener" {
  count             = length(var.tg_names) 
  load_balancer_arn = var.lb_arn
  port              = lookup(element(var.tg_names, count.index), "port")
  protocol          = lookup(element(var.tg_names, count.index), "protocol")

  default_action {
      target_group_arn = aws_lb_target_group.target_group.*.arn[count.index]
      type             = "forward"
  }

}

resource "aws_ecs_service" "service" {
  count           = length(var.containers) 
  name            = lookup(element(var.containers, count.index), "name")
  cluster         = var.cluster_id
  task_definition = "${element(var.task_family, count.index)}:${max("${element(var.task_revison, count.index)}", "${element(var.task_revison, count.index)}")}"
  desired_count   = lookup(element(var.containers, count.index), "desired_count")
  launch_type       = "EC2"

  ordered_placement_strategy {
      type  = "binpack"
      field = "memory"
  }

  dynamic "load_balancer" {
    for_each = lookup(element(var.containers, count.index), "load_balancers")
    content {
        target_group_arn = aws_lb_target_group.target_group.*.arn[load_balancer.value.target_group_arn]
        container_name   = load_balancer.value.container_name
        container_port   = load_balancer.value.container_port
    }
  }

  network_configuration {
    subnets = var.subnets
    security_groups = var.security_group
  }

}
