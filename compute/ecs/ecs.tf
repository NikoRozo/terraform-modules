#--------------------------------------------------------------
# Estos modulos crea los recursos necesarios el Cluster ECS
#--------------------------------------------------------------

# Global Variable
variable "name"                { }
variable "tags"                { }
# Variable Security
variable "vpc_id"              { }
variable "subnets"             { }
variable "ingress_rule"        { }
# Variable Launch
variable "ami"                 { }
variable "instance_type"       { }
variable "key_name"            { }
# Variable Autoscalling
variable "max_size"            { default = 1 }
variable "min_size"            { default = 1 }
variable "desired_capacity"    { default = 1 }
variable "private_subnet_ids"  { }
# Variable Logs
variable "logs_retention_in_days" {
  type        = number
  default     = 90
  description = "Specifies the number of days you want to retain log events"
}

module "sg_ecs" {
    source = "../../security/security_group"

    name = var.name
    tags = var.tags
    vpc_id = var.vpc_id
    ingress_rule = var.ingress_rule
    cidrs = var.subnets
}

module "lb" {
    source = "./elb"

    name = "${var.name}-nlb"
    tags = var.tags
    vpc_id = var.vpc_id
    private_ids = var.private_subnet_ids
    tipo = "network"
}

module "launch" {
    source = "./launch_config"
    
    name = var.name
    ami = var.ami
    instance_type = var.instance_type
    key_name = var.key_name
    security_groups = "${module.sg_ecs.sg_id}"
    ecs_cluster = "${var.name}-ecs-cluster"
}

module "auntoscalling" {
    source = "./autoscalling"
    
    name = var.name
    tags = var.tags
    max_size = var.max_size
    min_size = var.min_size
    desired_capacity = var.desired_capacity
    private_subnet_ids = var.private_subnet_ids
    launch_config = "${module.launch.launch_name}"
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.name}-ecs-cluster"
  
  tags  = merge(
    var.tags,
    { Name = "${var.name}-ecs-cluster" },
  )
}

resource "aws_cloudwatch_log_group" "logs" {
  name              = "/logs/ecs/service/alfa-dg"
  retention_in_days = var.logs_retention_in_days
  tags  = merge(
    var.tags,
    { Name = var.name },
  )
}

output "cluster_id" { value = "${aws_ecs_cluster.ecs_cluster.id}" }
output "lb_dns_name" { value = "${module.lb.lb_dns_name}" }
output "lb_arn" { value = "${module.lb.lb_arn}" }
output "sg_id" { value = "${module.sg_ecs.sg_id}" }
