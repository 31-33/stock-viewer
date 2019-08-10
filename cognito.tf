resource "aws_cognito_user_pool" "user_pool" {
  name = "stock_viewer_user_pool"
  username_attributes = ["email"]

  admin_create_user_config {
    allow_admin_create_user_only = false
  }
  auto_verified_attributes = ["email"]
}

resource "aws_cognito_user_pool_client" "pool_client" {
  name = "stock_viewer_pool_client"
  user_pool_id = "${aws_cognito_user_pool.user_pool.id}"
}

resource "aws_cognito_identity_pool" "identity_pool" {
  identity_pool_name="stock_viewer_identity_pool"
  cognito_identity_providers {
    client_id = "${aws_cognito_user_pool_client.pool_client.id}"
    provider_name = "cognito-idp.us-east-1.amazonaws.com/${aws_cognito_user_pool.user_pool.id}"
    server_side_token_check = false
  }
}