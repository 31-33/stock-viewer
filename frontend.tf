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
  apiGateway: {
    REGION: "us-east-1",
    URL: "${aws_api_gateway_deployment.deployment.invoke_url}",
  },
};
  CONTENT
}



#Setting up an S3 Bucket to hold static front-end content
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

#Cloudfront Distribution
resource "aws_cloudfront_distribution" "website_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.react_bucket.bucket_domain_name}"
    origin_id = "s3-stock-data-viewer"
}

  enabled = true
  default_root_object = "index.html"

  default_cache_behavior {
	allowed_methods = [
	  "HEAD",
	  "GET"
	]
	cached_methods = [
	  "HEAD",
	  "GET"
	]
    default_ttl = 86400
    target_origin_id = "s3-stock-data-viewer"
    viewer_protocol_policy = "redirect-to-https"
    compress = true
	forwarded_values {
	  query_string = false
      headers = ["Origin"]

	  cookies {
		forward = "none"
	  }
	}
  }

  # SPA - Return index.html with 200 response for all paths
  custom_error_response {
    error_code = 404
    response_page_path = "/index.html"
    response_code = 200
    error_caching_min_ttl = 86400
	}

  # Use default cloudfront SSL cert
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
	geo_restriction {
	  restriction_type = "none"
	}
  }
	}

output "cloudfront_domain" {
  value = "${aws_cloudfront_distribution.website_distribution.domain_name}"
  }
  

