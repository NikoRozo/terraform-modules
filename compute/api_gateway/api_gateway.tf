#--------------------------------------------------------------
# Estos modulos crea los recursos necesarios el API Gateway
#--------------------------------------------------------------

variable "name"         { default = "api" }
variable "tags"         { }
variable "lb_arns"      { }
variable "cognito_arns" { }
variable "dns_name"     { }
variable "stage_name"   { default = "v1"}

module "vpc_link" {
    source = "./vpc_link"

    name = "${var.name}-link"
    tags = var.tags
    target_arns = var.lb_arns
}

resource "aws_iam_role" "cloudwatch" {
  name = "api_gateway_cloudwatch"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloudwatch" {
  name = "APIGateWayAlfaLogs"
  role = aws_iam_role.cloudwatch.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents",
                "logs:GetLogEvents",
                "logs:FilterLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_api_gateway_account" "demo" {
  cloudwatch_role_arn = aws_iam_role.cloudwatch.arn
}

resource "aws_api_gateway_rest_api" "main" {
  name = "${var.name}-api"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags  = merge(
    var.tags,
    { Name = "${var.name}" },
  )
}

resource "aws_api_gateway_authorizer" "auth" {
  name            = "${var.name}-api-auth"
  rest_api_id     = aws_api_gateway_rest_api.main.id
  type            = "COGNITO_USER_POOLS"
  identity_source = "method.request.header.Authorization"
  provider_arns   = [var.cognito_arns]
}

resource "aws_api_gateway_resource" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "payments"
}

resource "aws_api_gateway_method" "main" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.main.id
  http_method      = "GET"
  authorization    = "COGNITO_USER_POOLS"
  authorizer_id    = aws_api_gateway_authorizer.auth.id
  authorization_scopes = ["payments/inquiry"]

  request_parameters = {
    "method.request.querystring.payid" = false
  }
}

resource "aws_api_gateway_integration" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.main.id
  http_method = aws_api_gateway_method.main.http_method

  type                    = "HTTP"
  integration_http_method = "GET"
  uri                     = "${var.dns_name}:8090/inquiry"
  
  connection_type         = "VPC_LINK"
  connection_id           = module.vpc_link.vpc_link
  
  request_parameters = {
    "integration.request.querystring.payid" = "method.request.querystring.payid"
  }

}

resource "aws_api_gateway_method_response" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.main.id
  http_method = aws_api_gateway_method.main.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.main.id
  http_method = aws_api_gateway_method.main.http_method
  status_code = aws_api_gateway_method_response.main.status_code
  selection_pattern = "-"

  response_templates = {
    "application/json" = ""
  }
}

#
# Payment
#

resource "aws_api_gateway_method" "main_post" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.main.id
  http_method      = "POST"
  authorization    = "COGNITO_USER_POOLS"
  authorizer_id    = aws_api_gateway_authorizer.auth.id
  authorization_scopes = ["payments/pay"]
}

resource "aws_api_gateway_integration" "main_post" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.main.id
  http_method = aws_api_gateway_method.main_post.http_method

  type                    = "HTTP"
  integration_http_method = "POST"
  uri                     = "${var.dns_name}:8087/payments/api/v1/processpayment"
  
  connection_type         = "VPC_LINK"
  connection_id           = module.vpc_link.vpc_link
}

resource "aws_api_gateway_method_response" "main_post" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.main.id
  http_method = aws_api_gateway_method.main_post.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "main_post" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.main.id
  http_method = aws_api_gateway_method.main_post.http_method
  status_code = aws_api_gateway_method_response.main_post.status_code
  selection_pattern = "-"

  response_templates = {
    "application/json" = ""
  }
}

#
# edit Schedule
#

resource "aws_api_gateway_method" "main_put" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.main.id
  http_method      = "PUT"
  #authorization    = "NONE"
  authorization    = "COGNITO_USER_POOLS"
  authorizer_id    = aws_api_gateway_authorizer.auth.id
  authorization_scopes = ["payments/updateSchedule"]
}

resource "aws_api_gateway_integration" "main_put" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.main.id
  http_method = aws_api_gateway_method.main_put.http_method

  type                    = "HTTP"
  integration_http_method = "PUT"
  uri                     = "${var.dns_name}:8080/schedule/api/v1/editPaymentScheduleStatus"
  
  connection_type         = "VPC_LINK"
  connection_id           = module.vpc_link.vpc_link
}

resource "aws_api_gateway_method_response" "main_put" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.main.id
  http_method = aws_api_gateway_method.main_put.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "main_put" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.main.id
  http_method = aws_api_gateway_method.main_put.http_method
  status_code = aws_api_gateway_method_response.main_put.status_code
  selection_pattern = "-"

  response_templates = {
    "application/json" = ""
  }
}

#
# kit de Bienvenida
#

resource "aws_api_gateway_resource" "main_noti" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "notifications"
}

resource "aws_api_gateway_method" "main_post_noti" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.main_noti.id
  http_method      = "POST"
  #authorization    = "NONE"
  authorization    = "COGNITO_USER_POOLS"
  authorizer_id    = aws_api_gateway_authorizer.auth.id
  authorization_scopes = ["notificacion/kit"]
}

resource "aws_api_gateway_integration" "main_post_noti" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.main_noti.id
  http_method = aws_api_gateway_method.main_post_noti.http_method

  type                    = "HTTP"
  integration_http_method = "POST"
  uri                     = "${var.dns_name}:8086/issuingprocess/api/v1/sendemail"
  
  connection_type         = "VPC_LINK"
  connection_id           = module.vpc_link.vpc_link
}

resource "aws_api_gateway_method_response" "main_post_noti" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.main_noti.id
  http_method = aws_api_gateway_method.main_post_noti.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "main_post_noti" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.main_noti.id
  http_method = aws_api_gateway_method.main_post_noti.http_method
  status_code = aws_api_gateway_method_response.main_post_noti.status_code
  selection_pattern = "-"

  response_templates = {
    "application/json" = ""
  }
}

#
#
#

resource "aws_api_gateway_deployment" "main" {
  depends_on  = [aws_api_gateway_integration.main]
  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name  = var.stage_name

  lifecycle {
    create_before_destroy = true
  }
}

#resource "aws_api_gateway_method_settings" "s" {
#  rest_api_id = aws_api_gateway_rest_api.main.id
#  stage_name  = var.stage_name
#  method_path = "*/*"

#  settings {
#    metrics_enabled = true
#    data_trace_enabled = true
#    logging_level   = "INFO"
#  }
#}

resource "aws_cloudwatch_log_group" "example" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.main.id}/${var.stage_name}"
  retention_in_days = 7
}

// API Gateway endpoint
output "api_gateway_endpoint" { value = "${aws_api_gateway_deployment.main.invoke_url}" }
output "api_id" { value = "${aws_api_gateway_rest_api.main.id}" }