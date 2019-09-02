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

data "aws_route53_zone" "external" {
  name = "amazonaws.com"
}

# Encapsulate generating a certificate and running Route 53
module "cert" {
  source = "github.com/azavea/terraform-aws-acm-certificate?ref=0.1.0"
  
  
    providers = {
    aws.acm_account     = "aws.certificates"
    aws.route53_account = "aws.dns"
    }

  domain_name           = "amazonaws.com"
  subject_alternative_names = ["*.amazonaws.com"]
  hosted_zone_id        = "${data.aws_route53_zone.external.zone_id}"
  validation_record_ttl = "60"
}

#Distributing CloudFront
resource "aws_cloudfront_distribution" "distribution" {
  origin {
	domain_name = "${aws_s3_bucket.react_bucket.bucket}.s3.amazonaws.com"
	origin_id = "website"
  }
  enabled = true
  is_ipv6_enabled = true

  aliases = [
	"${var.domain_name}"
  ]

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
	forwarded_values {
	  query_string = false
	  cookies {
		forward = "none"
	  }
	}
	default_ttl = 3600
	max_ttl = 86400
	min_ttl = 0
	target_origin_id = "website"
	viewer_protocol_policy = "redirect-to-https"
	compress = true
  }

  ordered_cache_behavior {
	allowed_methods = ["HEAD", "GET"]
	cached_methods = ["HEAD", "GET"]
	forwarded_values {
	  cookies {
		forward = "none"
	  }
	  query_string = false
	}
	default_ttl = 31536000
	max_ttl = 31536000
	min_ttl = 31536000
	path_pattern = "assets/*"
	target_origin_id = "website"
	viewer_protocol_policy = "redirect-to-https"
	compress = true
  }

# Have to specify
  restrictions {
	geo_restriction {
	  restriction_type = "none"
	}
  }

	viewer_certificate {
		acm_certificate_arn      = "${module.cert.arn}"
		minimum_protocol_version = "TLSv1"
		ssl_support_method       = "sni-only"
	}

 
  # Do not want to cache 404's as it's a single page application
	error_caching_min_ttl = 0
	error_code = 404
  }
  

