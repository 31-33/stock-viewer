#creates the S3 bucket that stores the lambda function code
#lambda then retrieves the code from the bucket
resource "aws_s3_bucket" "lambda_bucket" {
    bucket    = "${var.s3_bucket}"
    acl       = "public-read"
    policy    = <<POLICY
{
    "Version":"2012-10-17",
    "Statement":[{
      "Sid":"AddPerm",
      "Effect":"Allow",
      "Principal":"*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::${var.s3_bucket}/*"]
    }]
}
POLICY

}

#bucket object allows the code to be uploaded from local system
resource "aws_s3_bucket_object" "lambda_code" {
    bucket  = "${aws_s3_bucket.lambda_bucket.id}"
    key  = "V${var.app_version}/code.zip"
    source = "lambdas/${var.app_version}/code.zip"
    acl = "public-read"
}


#lambda function that gets the code from the S3 bucket
resource "aws_lambda_function" "lambda_function" {
    function_name   = "test-function-tf"

    s3_bucket       = "${aws_s3_bucket.lambda_bucket.id}"
    s3_key          = "${aws_s3_bucket_object.lambda_code.key}"

    handler         = "lambda_function.lambda_handler"
    runtime         = "python3.7"

    role = "${aws_iam_role.lambda_role.arn}"
}

#IAM role for the lambda function
resource "aws_iam_role" "lambda_role" {
    name =  "test-example-lambda"
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

#allows access from the API to invoke the lambda
resource "aws_lambda_permission" "api_gw" {
    statement_id    = "AllowAPIGatewayInvoke"
    action          = "lambda:InvokeFunction"
    function_name   = "${aws_lambda_function.lambda_function.arn}"
    principal       = "apigateway.amazonaws.com"

    source_arn      = "${aws_api_gateway_deployment.api_deployment.execution_arn}/*/*"
}