#--------------------------------------------------------------
# Estos modulos crea los recursos necesarios para DynamoDB
#--------------------------------------------------------------

variable "name"    { default = "secrets" }
variable "secrets" { type = map(string) }

resource "aws_secretsmanager_secret" "secrets" {
  name = var.name
  
  lifecycle { create_before_destroy = true }
}

resource "aws_secretsmanager_secret_version" "secrets" {
  secret_id     = aws_secretsmanager_secret.secrets.id
  secret_string = jsonencode(var.secrets)

  lifecycle { create_before_destroy = true }
}

output "secrets" { value = "${aws_secretsmanager_secret_version.secrets.secret_string}" }