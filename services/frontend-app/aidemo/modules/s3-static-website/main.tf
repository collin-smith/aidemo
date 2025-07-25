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

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
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
