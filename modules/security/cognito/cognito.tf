#--------------------------------------------------------------
# Estos modulos crea los recursos necesarios para el WAF
#--------------------------------------------------------------

variable "name"      { default = "cognito" }
variable "tags"      { }
variable "clients"   { }
variable "resources" { }

resource "aws_cognito_user_pool" "pool" {
  name = var.name

  tags  = merge(
    var.tags,
    { Name = "${var.name}" },
  )
}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = var.name
  user_pool_id = aws_cognito_user_pool.pool.id
}

resource "aws_cognito_resource_server" "resource" {
  count = length(var.resources)
  identifier = lookup(element(var.resources, count.index), "identifier")
  name       = lookup(element(var.resources, count.index), "name")

  dynamic "scope" {
    for_each = lookup(element(var.resources, count.index), "scopes")
    content {
        scope_name        = scope.value.scope_name
        scope_description = scope.value.scope_description
    }
  }

  user_pool_id = aws_cognito_user_pool.pool.id
}

resource "aws_cognito_user_pool_client" "client" {
  count = length(var.clients)
  name  = lookup(element(var.clients, count.index), "name")
  generate_secret     = true
  
  supported_identity_providers = ["COGNITO"]
  allowed_oauth_flows = lookup(element(var.clients, count.index), "allowed_oauth_flows")

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes = lookup(element(var.clients, count.index), "allowed_oauth_scopes")

  user_pool_id = aws_cognito_user_pool.pool.id
}

output "cognito_arn" { value = "${aws_cognito_user_pool.pool.arn}" }
output "client_secret" { value = "${aws_cognito_user_pool_client.client.*.client_secret}" }
output "client_id" { value = "${aws_cognito_user_pool_client.client.*.id}" }
output "scope_identifiers" { value = "${aws_cognito_resource_server.resource.*.scope_identifiers}" }
output "cognito_endpoint" { value = "https://${var.name}.auth.us-east-2.amazoncognito.com/oauth2/token" }