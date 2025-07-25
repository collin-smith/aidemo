####################################################
# S3 static website bucket
####################################################
resource "aws_s3_bucket" "s3-static-website" {
  bucket = var.bucket_name
  tags = merge(
  var.common_tags,
    {
      Name = "S3 Bucket"
    }
  )
}

####################################################
# S3 public access settings
####################################################
resource "aws_s3_bucket_public_access_block" "static_site_bucket_public_access" {
  bucket = aws_s3_bucket.s3-static-website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

}




####################################################
# S3 CORS Configuration settings
####################################################
resource "aws_s3_bucket_cors_configuration" "s3-static-website_cors" {
  bucket = aws_s3_bucket.s3-static-website.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET","PUT", "POST","DELETE"]
    allowed_origins = ["*"]
    expose_headers  = []
    max_age_seconds = 30000
  }

}


####################################################
# S3 bucket static website configuration
####################################################
resource "aws_s3_bucket_website_configuration" "static_site_bucket_website_config" {
  bucket = aws_s3_bucket.s3-static-website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

module "template_files" {
    source = "hashicorp/dir/template"
   base_dir = "${var.source_files}" 
}

resource "aws_s3_object" "hosting_bucket_files" {
    bucket = aws_s3_bucket.s3-static-website.id

    for_each = module.template_files.files

    key = each.key
    content_type = each.value.content_type

    source  = each.value.source_path
    content = each.value.content

    etag = each.value.digests.md5
}

##################
# Adding S3 bucket as trigger the textext trigger and giving the required permissions
##################
resource "aws_s3_bucket_notification" "aws-lambda-trigger" {
bucket = "${aws_s3_bucket.s3-static-website.id}"
lambda_function {
lambda_function_arn = "${var.lambda_function_arn}"
events              = ["s3:ObjectCreated:*"]
#filter_prefix       = "file-prefix" #Optional
filter_suffix       = ".pdf" #Optional
}
}

resource "aws_lambda_permission" "test" {
statement_id  = "AllowS3Invoke"
action        = "lambda:InvokeFunction"
function_name = "${var.lambda_function_name}"
principal = "s3.amazonaws.com"
source_arn = "arn:aws:s3:::${aws_s3_bucket.s3-static-website.id}"
}
