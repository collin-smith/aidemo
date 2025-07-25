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
  default     = "s3storage202507241322"
}

variable "vpc_cidr_block" {
  description = "VPC Cidr block"
  default     = "10.0.0.0/16"
}

variable "vpc_id" {
  description = "VPC Id"
  default     = "vpc-07472f3015261ff50"
}

variable "public_subnet_ids" {
  description = "Public subnet ids"
  default     =   [
  "subnet-067996f2fa119290a",
  "subnet-0bc52a9d1be6ce4e9",
  "subnet-07ee301fd731eab27",
]
}

variable "publicroutetableid" {
  type        = string
  description = "RouteTableId"
  default     = "rtb-091cc506bc20fe5bc"
}

variable "private_subnet_ids" {
  description = "Private subnet ids"
  default     =   [
  "subnet-0f99329dc5669fc8a",
  "subnet-0f2cb97b819cde04e",
  "subnet-0b3761c2929607980",
]
}

variable "privateroutetableid" {
  type        = string
  description = "RouteTableId"
  default     = "rtb-08bafb41dd7b86057"
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

