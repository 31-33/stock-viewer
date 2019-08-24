resource "aws_dynamodb_table" "user_subscriptions_table" {
  name = "subscriptions"
  billing_mode = "PROVISIONED"
  read_capacity = 5
  write_capacity = 5

  lifecycle {
    ignore_changes = [
      "read_capacity",
      "write_capacity"
    ]
  }

  hash_key = "userId"

  attribute {
    name = "userId"
    type = "S"
  }
}

module "dynamodb_autoscaler" {
    source                       = "git::https://github.com/cloudposse/terraform-aws-dynamodb-autoscaler.git?ref=master"
    name = "dynamo_autoscaler"

    dynamodb_table_name = "${aws_dynamodb_table.user_subscriptions_table.id}"
    dynamodb_table_arn = "${aws_dynamodb_table.user_subscriptions_table.arn}"
    autoscale_write_target       = 50
    autoscale_read_target        = 50
    autoscale_min_read_capacity  = 5
    autoscale_max_read_capacity  = 20
    autoscale_min_write_capacity = 5
    autoscale_max_write_capacity = 20
}