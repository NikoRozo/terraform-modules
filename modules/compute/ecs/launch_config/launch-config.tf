#--------------------------------------------------------------
# Este modulo crea los recursos necesarios para crear Autoscalling Group
#--------------------------------------------------------------

variable "name"              { }
variable "ami"               { }
variable "instance_type"     { }
variable "key_name"          { }
variable "security_groups"   { }
variable "ecs_cluster"       { }

resource "aws_iam_role" "ecs-instance-role" {
    name                = "ecs-alfa-instance-role"
    path                = "/"
    assume_role_policy  = data.aws_iam_policy_document.ecs-instance-policy.json
}

data "aws_iam_policy_document" "ecs-instance-policy" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
            type        = "Service"
            identifiers = ["ec2.amazonaws.com"]
        }
    }
}

resource "aws_iam_role_policy_attachment" "ecs-instance-role-attachment" {
    role       = aws_iam_role.ecs-instance-role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs-instance-profile" {
    name = "ecs-instance-profile-alfa-dg"
    path = "/"
    role = aws_iam_role.ecs-instance-role.id
    #provisioner "local-exec" {
    #  command = "sleep 10"
    #}
}

resource "aws_launch_configuration" "ecs-launch-configuration" {
    name_prefix           = "${var.name}_"
    image_id              = var.ami
    instance_type         = var.instance_type
    iam_instance_profile  = aws_iam_instance_profile.ecs-instance-profile.id

    #root_block_device {
    #  volume_type = "standard"
    #  volume_size = 100
    #  delete_on_termination = true
    #}

    lifecycle {
      create_before_destroy = true
    }

    security_groups             = var.security_groups
    associate_public_ip_address = "true"
    key_name                    = var.key_name
    user_data                   = <<EOF
                                  #!/bin/bash
                                  echo ECS_CLUSTER=${var.ecs_cluster} >> /etc/ecs/ecs.config
                                  sudo yum update -y ecs-init
                                  sudo systemctl restart docker
                                  EOF
}

output "launch_name" { value = "${aws_launch_configuration.ecs-launch-configuration.*.name}" }
output "launch_id" { value = "${aws_launch_configuration.ecs-launch-configuration.*.id}" }