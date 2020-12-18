#--------------------------------------------------------------
# Estos modulos crea los recursos necesarios para DynamoDB
#--------------------------------------------------------------

variable "name"             { default = "dynamo" }
variable "tables"           { }
variable "tags"             { }
variable "vpc_id"           { }
variable "route_table_ids"  { }

resource "aws_kms_key" "mykey" {
  description             = "Llave de encripción del estado de dynamodb"
  deletion_window_in_days = 10
}

resource "aws_dynamodb_table" "table" {
  count          = length(var.tables)
  name           = lookup(element(var.tables, count.index), "name")
  billing_mode   = lookup(element(var.tables, count.index), "billing_mode")
  read_capacity  = lookup(element(var.tables, count.index), "read_capacity")
  write_capacity = lookup(element(var.tables, count.index), "write_capacity")
  hash_key       = lookup(element(var.tables, count.index), "hash_key")
  range_key      = lookup(element(var.tables, count.index), "range_key")

  dynamic "attribute" {
    for_each = lookup(element(var.tables, count.index), "attributes")
    content {
        name = attribute.value.name
        type = attribute.value.type
    }
  }

  dynamic "global_secondary_index" {
    for_each = lookup(element(var.tables, count.index), "global_secondary_indexs")
    content {
        name = global_secondary_index.value.name
        write_capacity = global_secondary_index.value.write_capacity
        read_capacity = global_secondary_index.value.read_capacity
        hash_key = global_secondary_index.value.hash_key
        range_key = global_secondary_index.value.range_key
        projection_type = global_secondary_index.value.projection_type
        non_key_attributes = global_secondary_index.value.non_key_attributes
    }
  }

  tags  = merge(
    var.tags,
    { Name = "${var.name}-${lookup(element(var.tables, count.index), "name")}" },
  )

  server_side_encryption {
    enabled = true
    kms_key_arn = aws_kms_key.mykey.arn
  }

  lifecycle { create_before_destroy = true }
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.us-east-2.dynamodb"

  tags  = merge(
    var.tags,
    { Name = "${var.name}-dyna-endpoint" },
  )
}

resource "aws_vpc_endpoint_route_table_association" "end_dynamo" {
  count           = length(var.route_table_ids)
  route_table_id  = element(var.route_table_ids, count.index)
  vpc_endpoint_id = aws_vpc_endpoint.dynamodb.id

  lifecycle { create_before_destroy = true }
}

output "dynamodb_arn" { value = "${aws_dynamodb_table.table.*.arn}" }