resource "aws_dynamodb_table" "user_subscriptions_table" {
  name = "subscriptions"
  billing_mode = "PROVISIONED"

  hash_key = "userId"

  attribute {
    name = "userId"
    type = "S"
  }
}