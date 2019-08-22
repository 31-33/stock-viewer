resource "aws_api_gateway_rest_api" "rest_api" {
    name        =  "rest-api"
    description =  "terraform api with lambda" 
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    "aws_api_gateway_method.stocklist_method",
    "aws_api_gateway_integration.stocklist_integration",
    "aws_api_gateway_method.stockdata_method",
    "aws_api_gateway_integration.stockdata_integration",
    "aws_api_gateway_method.subscriptions_method",
    "aws_api_gateway_integration.subscriptions_integration",
    "aws_api_gateway_method.subscribe_method",
    "aws_api_gateway_integration.subscribe_integration",
  ]
  rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
  stage_name = "application"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_authorizer" "api_auth" {
  name = "api_auth"
  rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
  type = "COGNITO_USER_POOLS"
  provider_arns = ["${aws_cognito_user_pool.user_pool.arn}"]
}


# stocklist
resource "aws_api_gateway_resource" "stocklist_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
  parent_id = "${aws_api_gateway_rest_api.rest_api.root_resource_id}"
  path_part = "stocklist"
}

resource "aws_api_gateway_method" "stocklist_method" {
  rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
  resource_id = "${aws_api_gateway_resource.stocklist_resource.id}"
  http_method = "GET"
  # authorization = "NONE"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = "${aws_api_gateway_authorizer.api_auth.id}"
}

resource "aws_api_gateway_integration" "stocklist_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
  resource_id = "${aws_api_gateway_resource.stocklist_resource.id}"
  http_method = "${aws_api_gateway_method.stocklist_method.http_method}"
  type = "AWS_PROXY"
  uri = "${aws_lambda_function.stocklist_lambda.invoke_arn}"
  integration_http_method = "POST"
}

resource "aws_api_gateway_method_response" "stocklist_method_response" {
  rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
  resource_id = "${aws_api_gateway_resource.stocklist_resource.id}"
  http_method = "${aws_api_gateway_method.stocklist_method.http_method}"
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

module "api-gateway-enable-cors-stocklist" {
  source  = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.0"
  api_id = "${aws_api_gateway_rest_api.rest_api.id}"
  api_resource_id = "${aws_api_gateway_resource.stocklist_resource.id}"
}


# stockdata
resource "aws_api_gateway_resource" "stockdata_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
  parent_id = "${aws_api_gateway_rest_api.rest_api.root_resource_id}"
  path_part = "stockdata"
}

resource "aws_api_gateway_method" "stockdata_method" {
  rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
  resource_id = "${aws_api_gateway_resource.stockdata_resource.id}"
  http_method = "GET"
  # authorization = "NONE"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = "${aws_api_gateway_authorizer.api_auth.id}"
}

resource "aws_api_gateway_integration" "stockdata_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
  resource_id = "${aws_api_gateway_resource.stockdata_resource.id}"
  http_method = "${aws_api_gateway_method.stockdata_method.http_method}"
  type = "AWS_PROXY"
  uri = "${aws_lambda_function.stockdata_lambda.invoke_arn}"
  integration_http_method = "POST"
}

resource "aws_api_gateway_method_response" "stockdata_method_response" {
  rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
  resource_id = "${aws_api_gateway_resource.stockdata_resource.id}"
  http_method = "${aws_api_gateway_method.stockdata_method.http_method}"
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

module "api-gateway-enable-cors-stockdata" {
  source  = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.0"
  api_id = "${aws_api_gateway_rest_api.rest_api.id}"
  api_resource_id = "${aws_api_gateway_resource.stockdata_resource.id}"
}


# subscriptions
resource "aws_api_gateway_resource" "subscriptions_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
  parent_id = "${aws_api_gateway_rest_api.rest_api.root_resource_id}"
  path_part = "subscriptions"
}

resource "aws_api_gateway_method" "subscriptions_method" {
  rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
  resource_id = "${aws_api_gateway_resource.subscriptions_resource.id}"
  http_method = "GET"
  # authorization = "NONE"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = "${aws_api_gateway_authorizer.api_auth.id}"
}

resource "aws_api_gateway_integration" "subscriptions_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
  resource_id = "${aws_api_gateway_resource.subscriptions_resource.id}"
  http_method = "${aws_api_gateway_method.subscriptions_method.http_method}"
  type = "AWS_PROXY"
  uri = "${aws_lambda_function.subscriptions_lambda.invoke_arn}"
  integration_http_method = "POST"
}

resource "aws_api_gateway_method_response" "subscriptions_method_response" {
  rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
  resource_id = "${aws_api_gateway_resource.subscriptions_resource.id}"
  http_method = "${aws_api_gateway_method.subscriptions_method.http_method}"
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

module "api-gateway-enable-cors-subscriptions" {
  source  = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.0"
  api_id = "${aws_api_gateway_rest_api.rest_api.id}"
  api_resource_id = "${aws_api_gateway_resource.subscriptions_resource.id}"
}


# subscribe
resource "aws_api_gateway_resource" "subscribe_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
  parent_id = "${aws_api_gateway_rest_api.rest_api.root_resource_id}"
  path_part = "subscribe"
}

resource "aws_api_gateway_method" "subscribe_method" {
  rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
  resource_id = "${aws_api_gateway_resource.subscribe_resource.id}"
  http_method = "POST"
  # authorization = "NONE"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = "${aws_api_gateway_authorizer.api_auth.id}"
}

resource "aws_api_gateway_integration" "subscribe_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
  resource_id = "${aws_api_gateway_resource.subscribe_resource.id}"
  http_method = "${aws_api_gateway_method.subscribe_method.http_method}"
  type = "AWS_PROXY"
  uri = "${aws_lambda_function.subscribe_lambda.invoke_arn}"
  integration_http_method = "POST"
}

resource "aws_api_gateway_method_response" "subscribe_method_response" {
  rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
  resource_id = "${aws_api_gateway_resource.subscribe_resource.id}"
  http_method = "${aws_api_gateway_method.subscribe_method.http_method}"
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

module "api-gateway-enable-cors-subscribe" {
  source  = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.0"
  api_id = "${aws_api_gateway_rest_api.rest_api.id}"
  api_resource_id = "${aws_api_gateway_resource.subscribe_resource.id}"
}
