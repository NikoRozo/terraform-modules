#--------------------------------------------------------------
# Estos modulos crea los recursos necesarios para ROL Task Definition y Service
#--------------------------------------------------------------

resource "aws_iam_role" "ecs_service_role" {
    name                = "ecs-service-role-alfa-dg"
    path                = "/"
    assume_role_policy  = data.aws_iam_policy_document.ecs_service_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_service_role_attachment" {
    role       = aws_iam_role.ecs_service_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

data "aws_iam_policy_document" "ecs_service_policy" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
            type        = "Service"
            identifiers = ["ecs.amazonaws.com", "ecs-tasks.amazonaws.com"]
        }
    }
}

resource "aws_iam_policy" "policy_ecs_service" {
  name        = "AmazonAlfaDgECSOnlyAccess"
  path        = "/"
  description = "Politica Alfa"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:AttachNetworkInterface",
        "ec2:CreateNetworkInterface",
        "ec2:CreateNetworkInterfacePermission",
        "ec2:DeleteNetworkInterface",
        "ec2:DeleteNetworkInterfacePermission",
        "ec2:Describe*",
        "ec2:DetachNetworkInterface",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:DeregisterTargets",
        "elasticloadbalancing:Describe*",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
        "elasticloadbalancing:RegisterTargets",
        "iam:PassRole",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:DescribeLogStreams",
        "logs:CreateLogStream",
        "logs:CreateLogGroup",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_service_role_attachment_alfa" {
    role       = aws_iam_role.ecs_service_role.name
    policy_arn = aws_iam_policy.policy_ecs_service.arn
}

resource "aws_iam_role" "ecs_task_exec_role" {
    name                = "ecs-task-exec-role-alfa-dg"
    path                = "/"
    assume_role_policy  = data.aws_iam_policy_document.ecs_task_exec_policy.json
}

data "aws_iam_policy_document" "ecs_task_exec_policy" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
            type        = "Service"
            identifiers = ["ec2.amazonaws.com", "ecs.amazonaws.com", "ecs-tasks.amazonaws.com", "dynamodb.amazonaws.com"]
        }
    }
}

resource "aws_iam_policy" "policy_alfa" {
  name        = "AmazonAlfaDgECSAccess"
  path        = "/"
  description = "Politica Alfa"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ses:SendEmail",
        "ses:SendTemplatedEmail",
        "ses:SendRawEmail",
        "ses:SendBulkTemplatedEmail",
        "kms:Describe*", 
        "kms:Get*", 
        "kms:List*",
        "kms:Decrypt",
        "kms:Encrypt",
        "kms:GenerateDataKey",
        "secretsmanager:DescribeSecret",
        "secretsmanager:GetSecretValue",
        "dynamodb:BatchGet*",
        "dynamodb:DescribeStream",
        "dynamodb:DescribeTable",
        "dynamodb:Get*",
        "dynamodb:Query",
        "dynamodb:Scan",
        "dynamodb:BatchWrite*",
        "dynamodb:CreateTable",
        "dynamodb:Delete*",
        "dynamodb:Update*",
        "dynamodb:PutItem",
        "s3:GetObject",
        "s3:GetBucketLocation",
        "s3:ListAllMyBuckets"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "ecs_task_role_attachment_alfa" {
    role       = aws_iam_role.ecs_task_exec_role.name
    policy_arn = aws_iam_policy.policy_alfa.arn
}


output "ecs_task_exec_role" { value = "${aws_iam_role.ecs_task_exec_role.arn}" }
output "ecs_service_role" { value = "${aws_iam_role.ecs_service_role.arn}" }