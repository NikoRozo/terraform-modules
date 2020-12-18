provider "aws" {
    region="us-east-1"
    profile = "dev"
}

variable "name"              { }
variable "limit_amount"      { }
variable "perc_limit_notify" { }
variable "emails"            { }

module "task_definition" {
    source = "github.com/NikoRozo/terraform-modules/modules/billing/budgets"

    name = var.name
    limit_amount = var.limit_amount
    period_start = var.period_start
    perc_limit_notify = var.perc_limit_notify
    emails = var.emails
}