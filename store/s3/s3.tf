#--------------------------------------------------------------
# Estos modulos crea los recursos necesarios el Cluster ECS
#--------------------------------------------------------------

variable "name"                { }
variable "tags"                { }
variable "vpc_id"              { }
variable "route_table_ids"     { }

resource "aws_s3_bucket" "bucket" {
  bucket = var.name
  acl    = "private"
  force_destroy = true

  tags  = merge(
    var.tags,
    { Name = var.name },
  )
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.us-east-2.s3"

  tags  = merge(
    var.tags,
    { Name = "${var.name}-s3-endpoint" },
  )
}

resource "aws_vpc_endpoint_route_table_association" "end_s3" {
  count           = length(var.route_table_ids)
  route_table_id  = element(var.route_table_ids, count.index)
  vpc_endpoint_id = aws_vpc_endpoint.s3.id

  lifecycle { create_before_destroy = true }
}

output "name" { value = "${var.name}" }
output "id" { value = "${aws_s3_bucket.bucket.id}" }
output "arn" { value = "${aws_s3_bucket.bucket.arn}" }
output "bucket_domain_name" { value = "${aws_s3_bucket.bucket.bucket_domain_name}" }