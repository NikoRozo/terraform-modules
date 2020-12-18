#--------------------------------------------------------------
# Estos modulos crea los recursos necesarios para el WAF
#--------------------------------------------------------------

variable "name"     { default = "lb" }
variable "tags"     { }
variable "region"   { default = "us-east-2" }
variable "api_id"   { }

resource "aws_wafv2_web_acl" "main" {
  name  = var.name
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  /*rule {
    name     = "AWS-AWSManagedRulesAdminProtectionRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAdminProtectionRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesAdminProtectionRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
      sampled_requests_enabled   = true
    }
  }*/

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = var.name
    sampled_requests_enabled   = true
  }

  tags  = merge(
    var.tags,
    { Name = var.name },
  )
}

resource "aws_wafv2_web_acl_association" "main" {
  web_acl_arn  = aws_wafv2_web_acl.main.arn
  resource_arn = "arn:aws:apigateway:${var.region}::/restapis/${var.api_id}/stages/v1"
}