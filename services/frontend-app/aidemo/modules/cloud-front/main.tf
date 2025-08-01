data "aws_s3_bucket" "selected_bucket" {
  bucket = var.s3_bucket_id
}

####################################################
# Create AWS Cloudfront distribution
####################################################
resource "aws_cloudfront_origin_access_control" "cf-s3-oac" {
  name                              = "CloudFront S3 Frontend OAC"
  description                       = "CloudFront S3 Frontend OAC"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "cf-dist" {
  enabled             = true
  default_root_object = "index.html"

  origin {
    domain_name              = data.aws_s3_bucket.selected_bucket.bucket_regional_domain_name
    origin_id                = var.s3_bucket_id
    origin_access_control_id = aws_cloudfront_origin_access_control.cf-s3-oac.id
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.s3_bucket_id
    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_All"

  //To avoid the AccessDenied issues for sub pages in React applications(React Router)
  custom_error_response {
    error_code         = "403"
    response_page_path = "/index.html"
    response_code      = 200
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }




  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = merge(var.common_tags, {
    Name = "${var.naming_prefix}-cloudfront"
  })
}