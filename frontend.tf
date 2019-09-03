# AWS Region for S3 and other resources
provider "aws" {
  region = "us-west-2"
  alias = "main"
}

# AWS Region for Cloudfront (ACM certs only supports us-east-1)
provider "aws" {
  region = "us-east-1"
  alias = "cloudfront"
}

# Issue a CLI call to get a cert. Re-requests just return the ARN
data "external" "cert_request" {
  program = ["bash", "./req_cert.sh"]
  query = {
    site_name = "${var.site_name}"
  }
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



# Route53 Domain Name & Resource Records
resource "aws_route53_zone" "site_zone" {
  name = "${var.site_name}"
}
resource "aws_route53_record" "site_cname" {
  zone_id = "${aws_route53_zone.site_zone.zone_id}"
  name = "${var.site_name}"
  type = "NS"
  ttl = "30"
  records = [
    "${aws_route53_zone.site_zone.name_servers.0}",
    "${aws_route53_zone.site_zone.name_servers.1}",
    "${aws_route53_zone.site_zone.name_servers.2}",
    "${aws_route53_zone.site_zone.name_servers.3}"
  ]
}

# cloudfront distribution
resource "aws_cloudfront_distribution" "site_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.site_bucket.bucket_domain_name}"
    origin_id = "${var.site_name}-origin"
  }
  enabled = true
  aliases = ["${var.site_name}"]
  price_class = "PriceClass_100"
  default_root_object = "index.html"
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH",
                      "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.site_name}-origin"
    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }
    viewer_protocol_policy = "https-only"
    min_ttl                = 0
    default_ttl            = 1000
    max_ttl                = 86400
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    acm_certificate_arn = "${data.external.cert_request.result.CertificateArn}"
    ssl_support_method  = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016" # defaults wrong, set
  }
}