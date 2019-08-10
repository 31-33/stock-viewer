# Create config file containing the relevant variables for the front-end application
resource "local_file" "config-file" {
  filename = "compx527-group3/src/config.js"

  content = <<CONTENT
export default {
  cognito: {
    REGION: "us-east-1",
    USER_POOL_ID: "${aws_cognito_user_pool.user_pool.id}",
    APP_CLIENT_ID: "${aws_cognito_user_pool_client.pool_client.id}",
    IDENTITY_POOL_ID: "${aws_cognito_identity_pool.identity_pool.id}",
  },
};
  CONTENT
}

# Create an S3 Bucket to hold static front-end content
resource "aws_s3_bucket" "react_bucket" {
  bucket = "${var.website_bucket}"
  acl    = "public-read"
  depends_on = [local_file.config-file]

  policy = <<POLICY
{
    "Version":"2012-10-17",
    "Statement":[{
      "Sid":"AddPerm",
      "Effect":"Allow",
      "Principal":"*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::${var.website_bucket}/*"]
    }]
}
POLICY

  website {
    index_document = "index.html"
    error_document = "index.html"
  }

  provisioner "local-exec" {
    # Create build and copy artifacts into bucket
    command = "cd compx527-group3 && npm run build && aws s3 sync build s3://${var.website_bucket}"
  }

  provisioner "local-exec" {
    when = "destroy"
    # Delete contents of bucket so it may be de-provisioned
    command = "aws s3 rm s3://${var.website_bucket} --recursive"
  }
}
# TODO: Create cloudfront distribution, and enable HTTPS/TLS
# resource "aws_cloudfront_distribution" "s3_distribution" {
#   origin {
#     domain_name = "${aws_s3_bucket.react_bucket.bucket_regional_domain_name}"
#     origin_id = "myS3Origin"

#     s3_origin
#   }
# }

output "website_domain" {
  value = "${aws_s3_bucket.react_bucket.website_domain}"
}
output "website_endpoint" {
  value = "${aws_s3_bucket.react_bucket.website_endpoint}"
}
