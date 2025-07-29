####################################################
# Create S3 Static Website
####################################################
module "s3_website" {
  source        = "./modules/s3-static-website"
  bucket_name   = var.bucket_name_primary
  source_files  = "${var.sourcefiles}"

  common_tags   = merge(
    var.common_tags,
    {
      Name = "S3 Bucket"
    }
  )
  naming_prefix = "Naming Prefix - Dev"
}

####################################################
# Create AWS Cloudfront distribution
####################################################
module "cloud_front" {
  source        = "./modules/cloud-front"
  s3_bucket_id  = module.s3_website.static_website_id
  common_tags   = merge(
    var.common_tags,
    {
      Name = "Cloud Front Distribution"
    }
  )
  naming_prefix = "Naming Prefix - Dev"
}

####################################################
# S3 bucket policy to allow access from cloudfront
####################################################
module "s3_cf_policy_primary" {
  source                      = "./modules/s3-cf-policy"
  bucket_id                   = module.s3_website.static_website_id
  bucket_arn                  = module.s3_website.static_website_arn
  cloudfront_distribution_arn = module.cloud_front.cloudfront_distribution_arn
}

