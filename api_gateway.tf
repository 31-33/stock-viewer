resource "aws_api_gateway_rest_api" "rest_api" {
  name = "stock_viewer_api"
  description = "REST API to provide functionality for the COMPX527 group project, 'Stock Data Viewer'"
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
  stage_name = "application"
  depends_on = [
    "aws_api_gateway_integration.stocklist_integration"
  ]
}

resource "aws_api_gateway_authorizer" "api_auth" {
  name = "api_auth"
  rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
  type = "COGNITO_USER_POOLS"
  provider_arns = ["${aws_cognito_user_pool.user_pool.arn}"]
}

# stocklist
resource "aws_api_gateway_resource" "options_resource" {
  path_part = "stocklist"
  parent_id = "${aws_api_gateway_rest_api.rest_api.root_resource_id}"
  rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
}

resource "aws_api_gateway_method" "options_method" {
  rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
  resource_id = "${aws_api_gateway_resource.options_resource.id}"
  http_method = "OPTIONS"
  # authorization = "NONE"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = "${aws_api_gateway_authorizer.api_auth.id}"
}

resource "aws_api_gateway_method_response" "options_response" {
  rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
  resource_id = "${aws_api_gateway_resource.options_resource.id}"
  http_method = "${aws_api_gateway_method.options_method.http_method}"
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin" = true
  }
  depends_on = ["aws_api_gateway_method.options_method"]
}

resource "aws_api_gateway_integration" "options_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
  resource_id = "${aws_api_gateway_resource.options_resource.id}"
  http_method = "${aws_api_gateway_method.options_method.http_method}"
  type = "MOCK"
  depends_on = ["aws_api_gateway_method.options_method"]
}

resource "aws_api_gateway_integration_response" "options_integration_response" {
  rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
  resource_id = "${aws_api_gateway_resource.options_resource.id}"
  http_method = "${aws_api_gateway_method.options_method.http_method}"
  status_code = "${aws_api_gateway_method_response.options_response.status_code}"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type, X-Amz-Date, Authorization, X-Api-Key, X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'",
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  depends_on = [
    "aws_api_gateway_method_response.options_response",
    "aws_s3_bucket.react_bucket"
  ]
}

resource "aws_api_gateway_method" "stocklist_method" {
  rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
  resource_id = "${aws_api_gateway_resource.options_resource.id}"
  http_method = "GET"
  # authorization = "NONE"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = "${aws_api_gateway_authorizer.api_auth.id}"
}

resource "aws_api_gateway_method_response" "stocklist_response" {
  rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
  resource_id = "${aws_api_gateway_resource.options_resource.id}"
  http_method = "${aws_api_gateway_method.stocklist_method.http_method}"
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
  depends_on = ["aws_api_gateway_method.stocklist_method"]
}

resource "aws_api_gateway_integration" "stocklist_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
  resource_id = "${aws_api_gateway_resource.options_resource.id}"
  http_method = "${aws_api_gateway_method.stocklist_method.http_method}"
  integration_http_method = "GET"
  type = "AWS_PROXY"
  uri = "${aws_lambda_function.stocklist_lambda.invoke_arn}"
  depends_on = [
    "aws_api_gateway_method.stocklist_method",
    "aws_lambda_function.stocklist_lambda"
  ]
}

