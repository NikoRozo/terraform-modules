#--------------------------------------------------------------
# Este modulo crea los recursos necesarios para crear Autoscalling Group
#--------------------------------------------------------------

variable "name"                { default = "autoscalling" }
variable "tags"                { }
variable "max_size"            { default = 1 }
variable "min_size"            { default = 1 }
variable "desired_capacity"    { default = 1 }
variable "private_subnet_ids"  { }
variable "launch_config"       { }

locals {
  standard_tags = merge(
                    var.tags,
                    { Name = "${var.name}-ecs" },
                  )
}

resource "aws_autoscaling_group" "ecs-autoscaling-group" {
    name                        = "${var.name}-as"
    max_size                    = var.max_size
    min_size                    = var.min_size
    desired_capacity            = var.desired_capacity
    vpc_zone_identifier         = var.private_subnet_ids
    launch_configuration        = element(var.launch_config, 0)
    health_check_type           = "ELB"


    dynamic "tag" {
    for_each = local.standard_tags

      content {
        key                 = tag.key
        value               = tag.value
        propagate_at_launch = true
      }
     }

  }
