#creates the S3 bucket that stores the lambda function code
#lambda then retrieves the code from the bucket
resource "aws_s3_bucket" "lambda_bucket" {
    bucket    = "${var.lambda_bucket}"
    acl       = "private"
#     policy    = <<POLICY
# {
#     "Version":"2012-10-17",
#     "Statement":[{
#       "Sid":"AddPerm",
#       "Effect":"Allow",
#       "Principal":"*",
#       "Action":["s3:GetObject"],
#       "Resource":["arn:aws:s3:::${var.lambda_bucket}/*"]
#     }]
# }
# POLICY

    provisioner "local-exec" {
        when = "destroy"
        # Delete contents of bucket so it may be de-provisioned
        command = "aws s3 rm s3://${var.lambda_bucket} --recursive"
    }
}

resource "archive_file" "lambda_funcs" {
    type = "zip"
    output_path = "lambdas/${var.lambdas_version}/code.zip"
    source_dir = "lambdas/src"
} 
#bucket object allows the code to be uploaded from local system
resource "aws_s3_bucket_object" "lambda_code" {
    bucket  = "${aws_s3_bucket.lambda_bucket.id}"
    key  = "V${var.lambdas_version}/code.zip"
    source = "lambdas/${var.lambdas_version}/code.zip"
    acl = "public-read"
    depends_on = [archive_file.lambda_funcs]
}


#IAM role for the lambda function(s)
resource "aws_iam_role" "lambda_role" {
    name =  "lambda_role"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
    
}

#add policy for dynamodb

resource "aws_lambda_function" "stockdata_lambda" {
    function_name   = "stockdata"

    s3_bucket       = "${aws_s3_bucket.lambda_bucket.id}"
    s3_key          = "${aws_s3_bucket_object.lambda_code.key}"

    handler         = "stockdata.handler"
    runtime         = "nodejs8.10"

    role = "${aws_iam_role.lambda_role.arn}"
}

resource "aws_lambda_function" "stocklist_lambda" {
    function_name   = "stocklist"

    s3_bucket       = "${aws_s3_bucket.lambda_bucket.id}"
    s3_key          = "${aws_s3_bucket_object.lambda_code.key}"

    handler         = "stocklist.handler"
    runtime         = "nodejs8.10"

    role = "${aws_iam_role.lambda_role.arn}"
}

resource "aws_lambda_function" "subscriptions_lambda" {
    function_name   = "subscriptions"

    s3_bucket       = "${aws_s3_bucket.lambda_bucket.id}"
    s3_key          = "${aws_s3_bucket_object.lambda_code.key}"

    handler         = "subscriptions.lambda_handler" #"subscriptions.handler"
    runtime         = "python3.6" #"nodejs8.10"

    role = "${aws_iam_role.lambda_role.arn}"
}

resource "aws_lambda_function" "subscribe_lambda" {
    function_name   = "subscribe"

    s3_bucket       = "${aws_s3_bucket.lambda_bucket.id}"
    s3_key          = "${aws_s3_bucket_object.lambda_code.key}"

    handler         = "subscribe.lambda_handler"
    runtime         = "python3.6"

    role = "${aws_iam_role.lambda_role.arn}"
}

#allows access from the API to invoke the lambda
resource "aws_lambda_permission" "stockdata_api" {
    statement_id    = "AllowAPIGatewayInvoke"
    action          = "lambda:InvokeFunction"
    function_name   = "${aws_lambda_function.stockdata_lambda.arn}"
    principal       = "apigateway.amazonaws.com"

    source_arn      = "${aws_api_gateway_deployment.deployment.execution_arn}/*${aws_api_gateway_resource.stockdata_resource.path}"
}

resource "aws_lambda_permission" "stocklist_api" {
    statement_id    = "AllowAPIGatewayInvoke"
    action          = "lambda:InvokeFunction"
    function_name   = "${aws_lambda_function.stocklist_lambda.arn}"
    principal       = "apigateway.amazonaws.com"

    source_arn      = "${aws_api_gateway_deployment.deployment.execution_arn}/*${aws_api_gateway_resource.stocklist_resource.path}"
}

resource "aws_lambda_permission" "subscriptions_api" {
    statement_id    = "AllowAPIGatewayInvoke"
    action          = "lambda:InvokeFunction"
    function_name   = "${aws_lambda_function.subscriptions_lambda.arn}"
    principal       = "apigateway.amazonaws.com"

    source_arn      = "${aws_api_gateway_deployment.deployment.execution_arn}/*${aws_api_gateway_resource.subscriptions_resource.path}"
}

resource "aws_lambda_permission" "subscribe_api" {
    statement_id    = "AllowAPIGatewayInvoke"
    action          = "lambda:InvokeFunction"
    function_name   = "${aws_lambda_function.subscribe_lambda.arn}"
    principal       = "apigateway.amazonaws.com"

    source_arn      = "${aws_api_gateway_deployment.deployment.execution_arn}/*${aws_api_gateway_resource.subscribe_resource.path}"
}