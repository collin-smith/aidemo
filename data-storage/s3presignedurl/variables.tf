variable "python_version" {
  type        = string
  description = "Python version for lambdas"
  default     = "python3.10"
}

variable "aws_region" {
  type        = string
  description = "AWS region to use for resources."
  default     = "us-east-1"
}

variable "bucket_name" {
  type        = string
  description = "Name of the S3 Bucket"
  default     = "s3storage202507291118"
}

variable "vpc_cidr_block" {
  description = "VPC Cidr block"
  default     = "10.0.0.0/16"
}

variable "vpc_id" {
  description = "VPC Id"
  default     = "vpc-04b1037cede1ab4d6"
}

variable "public_subnet_ids" {
  description = "Public subnet ids"
  default     =   [
  "subnet-0adcf753fe3220788",
  "subnet-0b4f4da5690038ea0",
  "subnet-0ac43b4228527053c",
]
}

variable "publicroutetableid" {
  type        = string
  description = "RouteTableId"
  default     = "rtb-0597d244b3e8a58b7"
}

variable "private_subnet_ids" {
  description = "Private subnet ids"
  default     =   [
  "subnet-0eebdd7bcc8671981",
  "subnet-03e824a7c6549d52a",
  "subnet-0f0be4ccae7c556fa",
]
}

variable "privateroutetableid" {
  type        = string
  description = "RouteTableId"
  default     = "rtb-025c407676d95c8ab"
}

variable "common_tags" {
  description = "A list of common tags to be applied to all resources"
  type        = map(string)
  default = {
    Environment = "dev_react-presignedurl"
    Team        = "cloud team"
  }
}

variable "sourcefiles" {
  type        = string
  description = "Path of web files to upload"
  default     = "./dist"
}

