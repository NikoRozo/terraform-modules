variable "name"              { default = "budget" }
variable "limit_amount"      { default = "300"}
variable "period_start"      { default = "2017-07-01_00:00" }
variable "perc_limit_notify" { default = "80" }
variable "emails"            { }


resource "aws_budgets_budget" "budget" {
  for_each = var.services

  name              = var.name
  budget_type       = "COST"
  limit_amount      = var.limit_amount
  limit_unit        = "USD"
  time_period_start = var.period_start
  time_unit         = "MONTHLY"

  cost_filters = {
    Service = lookup(local.aws_services, each.key)
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = var.perc_limit_notify
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = var.emails
  }
}