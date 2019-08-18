resource "aws_api_gateway_rest_api" "api" {
    name        =  "rest-api"
    description =  "terraform api with lambda example" 
}

resource "aws_api_gateway_authorizer" "api_auth" {
  name = "api_auth"
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  
  type = "COGNITO_USER_POOLS"
  provider_arns = ["${aws_cognito_user_pool.user_pool.arn}"]
}

# resource "aws_api_gateway_base_path_mapping" "api" {
#   api_id = "${aws_api_gateway_rest_api.api.id}"
#   stage_name = "${aws_api_gateway_deployment.api_deployment.stage_name}"
# }

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [
    "aws_api_gateway_method.stockdata_get",
    "aws_api_gateway_integration.stockdata_get",
    "aws_api_gateway_method.stocklist_get",
    "aws_api_gateway_integration.stocklist_get",
    "aws_api_gateway_method.subscriptions_get",
    "aws_api_gateway_integration.subscriptions_get",
    "aws_api_gateway_method.subscribe_post",
    "aws_api_gateway_integration.subscribe_post",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  stage_name = "application"

  lifecycle {
    create_before_destroy = true
  }
}

#Configure each endpoint with respective lamdba
resource "aws_api_gateway_resource" "stockdata" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  parent_id   = "${aws_api_gateway_rest_api.api.root_resource_id}"
  path_part   = "stockdata"
}
resource "aws_api_gateway_method" "stockdata_get" {
    rest_api_id = "${aws_api_gateway_rest_api.api.id}"
    resource_id = "${aws_api_gateway_resource.stockdata.id}"
    http_method = "GET"
    authorization = "NONE"
}
resource "aws_api_gateway_integration" "stockdata_get" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.stockdata.id}"
  http_method = "${aws_api_gateway_method.stockdata_get.http_method}"
  type = "AWS_PROXY"
  uri = "${aws_lambda_function.stockdata_lambda.invoke_arn}"

  integration_http_method = "GET"
}
resource "aws_api_gateway_method_response" "stockdata_get_200" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.stockdata.id}"
  http_method = "${aws_api_gateway_method.stockdata_get.http_method}"
  status_code = "200"
}
resource "aws_api_gateway_method_response" "stockdata_get_400" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.stockdata.id}"
  http_method = "${aws_api_gateway_method.stockdata_get.http_method}"
  status_code = "400"
}
resource "aws_api_gateway_method_response" "stockdata_get_403" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.stockdata.id}"
  http_method = "${aws_api_gateway_method.stockdata_get.http_method}"
  status_code = "403"
}


resource "aws_api_gateway_resource" "stocklist" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  parent_id   = "${aws_api_gateway_rest_api.api.root_resource_id}"
  path_part   = "stocklist"
}
resource "aws_api_gateway_method" "stocklist_get" {
    rest_api_id = "${aws_api_gateway_rest_api.api.id}"
    resource_id = "${aws_api_gateway_resource.stocklist.id}"
    http_method = "GET"
    authorization = "NONE"
}
resource "aws_api_gateway_integration" "stocklist_get" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.stocklist.id}"
  http_method = "${aws_api_gateway_method.stocklist_get.http_method}"
  type = "AWS_PROXY"
  uri = "${aws_lambda_function.stocklist_lamda.invoke_arn}"

  integration_http_method = "GET"
}
resource "aws_api_gateway_method_response" "stocklist_get_200" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.stocklist.id}"
  http_method = "${aws_api_gateway_method.stocklist_get.http_method}"
  status_code = "200"
}
resource "aws_api_gateway_method_response" "stocklist_get_400" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.stocklist.id}"
  http_method = "${aws_api_gateway_method.stocklist_get.http_method}"
  status_code = "400"
}


resource "aws_api_gateway_resource" "subscriptions" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  parent_id   = "${aws_api_gateway_rest_api.api.root_resource_id}"
  path_part   = "subscriptions"
}
resource "aws_api_gateway_method" "subscriptions_get" {
    rest_api_id = "${aws_api_gateway_rest_api.api.id}"
    resource_id = "${aws_api_gateway_resource.subscriptions.id}"
    http_method = "GET"
    authorization = "NONE"
}
resource "aws_api_gateway_integration" "subscriptions_get" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.subscriptions.id}"
  http_method = "${aws_api_gateway_method.subscriptions_get.http_method}"
  type = "AWS_PROXY"
  uri = "${aws_lambda_function.subscriptions_lambda.invoke_arn}"

  integration_http_method = "GET"
}
resource "aws_api_gateway_method_response" "subscriptions_get_200" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.subscriptions.id}"
  http_method = "${aws_api_gateway_method.subscriptions_get.http_method}"
  status_code = "200"
}
resource "aws_api_gateway_method_response" "subscriptions_get_400" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.subscriptions.id}"
  http_method = "${aws_api_gateway_method.subscriptions_get.http_method}"
  status_code = "400"
}


resource "aws_api_gateway_resource" "subscribe" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  parent_id   = "${aws_api_gateway_rest_api.api.root_resource_id}"
  path_part   = "subscribe"
}
resource "aws_api_gateway_method" "subscribe_post" {
    rest_api_id = "${aws_api_gateway_rest_api.api.id}"
    resource_id = "${aws_api_gateway_resource.subscribe.id}"
    http_method = "POST"
    authorization = "NONE"
}
resource "aws_api_gateway_integration" "subscribe_post" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.subscribe.id}"
  http_method = "${aws_api_gateway_method.subscribe_post.http_method}"
  type = "AWS_PROXY"
  uri = "${aws_lambda_function.subscribe_lambda.invoke_arn}"

  integration_http_method = "POST"
}
resource "aws_api_gateway_method_response" "subscribe_post_200" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.subscribe.id}"
  http_method = "${aws_api_gateway_method.subscribe_post.http_method}"
  status_code = "200"
}
resource "aws_api_gateway_method_response" "subscribe_post_400" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.subscribe.id}"
  http_method = "${aws_api_gateway_method.subscribe_post.http_method}"
  status_code = "400"
}


output "api_test_url" {
  value = "${aws_api_gateway_deployment.api_deployment.invoke_url}"
}