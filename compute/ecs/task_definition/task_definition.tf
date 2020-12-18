#--------------------------------------------------------------
# Estos modulos crea los recursos necesarios para Task Definition
#--------------------------------------------------------------

variable "containers"         { }
variable "tags"               { }
variable "dns_lb"             { }
variable "ecs_service_role"   { }
variable "ecs_task_exec_role" { }

resource "aws_ecs_task_definition" "app" {
  count                 = length(var.containers) 
  family                = lookup(element(var.containers, count.index), "family")
  network_mode          = lookup(element(var.containers, count.index), "network_mode")
  container_definitions = templatefile(lookup(element(var.containers, count.index), "container_definitions"),
  {
      dns_lb = var.dns_lb
  })

  task_role_arn = var.ecs_task_exec_role
  execution_role_arn = var.ecs_service_role

  tags  = merge(
    var.tags,
    { Name = lookup(element(var.containers, count.index), "family") },
  )
}

output "family" { value = "${aws_ecs_task_definition.app.*.family}" }
output "revision" { value = "${aws_ecs_task_definition.app.*.revision}" }