#--------------------------------------------------------------
# Estos modulos crea los recursos necesarios para el SES
#--------------------------------------------------------------

variable "email"            { default = "email@example.com" }
variable "vpc_id"           { }
variable "tags"             { }
variable "sg"               { }

#resource "aws_ses_email_identity" "email" {
#  email = var.email
#}

resource "aws_vpc_endpoint" "ses" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.us-east-2.email-smtp"
  vpc_endpoint_type = "Interface"

  security_group_ids = var.sg

  tags  = merge(
    var.tags,
    { Name = "ses-endpoint" },
  )
}

#output "ses_arn" { value = "${aws_ses_email_identity.email.arn}" }