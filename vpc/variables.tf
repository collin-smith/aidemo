variable "aws_region" {
  description = "AWS region"
  type        = string
  default = "us-east-1"
}

variable "common_tags" {
  description = "A list of common tags to be applied to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Team        = "cloud team"
  }
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_count" {
  description = "Number of subnets"
  type        = map(number)
  default = {
    public  = 3,
    private = 3
  }
}

variable "public_subnet_cidr_blocks" {
  description = "Available CIDR blocks for public subnets"
  type        = list(string)
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
    "10.0.4.0/24"
  ]
}


variable "private_subnet_cidr_blocks" {
  description = "Available CIDR blocks for private subnets"
  type        = list(string)
  default = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24",
    "10.0.104.0/24",
  ]
}

variable "name" {
  description = "Friendly name of the new secret. The secret name can consist of uppercase letters, lowercase letters, digits, and any of the following characters: `/_+=.@-`"
  type        = string
  default     = "rds_secret"
}

variable "description" {
  description = "A description of the secret"
  type        = string
  default     = "The RDS Secret Description"
}

variable lambda_function_name {
  type = string
  default = "auth"
}

variable lambda_handler {
  type    = string
  default = "handler.app"
}

variable lambda_runtime {
  type    = string
  default = "nodejs18.x"
}