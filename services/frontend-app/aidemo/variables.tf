variable "aws_region" {
  type        = string
  description = "AWS region to use for resources."
  default     = "us-east-1"
}

variable "bucket_name_primary" {
  type        = string
  description = "Name of the S3 Bucket"
  default     = "s3cloudfrontvitereactapp202507242122"
}

variable "common_tags" {
  description = "A list of common tags to be applied to all resources"
  type        = map(string)
  default = {
    Environment = "dev_react-s3cloudfront"
    Team        = "cloud team"
  }
}

variable "sourcefiles" {
  type        = string
  description = "Path of web files to upload"
  default     = "./dist"
}