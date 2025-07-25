#AWS Policies to determine permission sets for AWS IAM Roles
#A policy is an object in AWS that, when associated with an identity or resource, defines their permissions. 
#AWS evaluates these policies when an IAM principal (user or role) makes a request.

data "aws_caller_identity" "current" {}

#S3 Bucket Policy
resource "aws_iam_policy" "iampolicy_s3client" {
  name        = "iampolicy_s3client"
  description = "IAM policy for Lambda to access the s3 client"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
                "*"
        ]
        Effect   = "Allow"
        Resource = [
                "arn:aws:s3:::${var.bucket_name}",
                "arn:aws:s3:::${var.bucket_name}/*"
            ]
      }
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name = "Policy to allow access to the S3 bucket"
    }
  )
}

#Bedrock Policy
resource "aws_iam_policy" "iampolicy_bedrockclient" {
  name        = "iampolicy_bedrockclient"
  description = "IAM policy for Lambda to access the bedrock client"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
                "bedrock:InvokeModel*",
                "bedrock:CreateInferenceProfile"
        ]
        Effect   = "Allow"
        Resource = [
                "arn:aws:bedrock:*::foundation-model/*",
                "arn:aws:bedrock:${var.aws_region}:${data.aws_caller_identity.current.account_id}:provisioned-model/*",
                "arn:aws:bedrock:${var.aws_region}:${data.aws_caller_identity.current.account_id}:inference-profile/*"
            ]
      }
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name = "Policy to allow access to Bedrock"
    }
  )
}

#DynamoDb Policy
#resource "aws_iam_policy" "iampolicy_dynamodbclient" {
#  name        = "iampolicy_dynamodbclient"
#  description = "IAM policy for Lambda to access the dynamodb client"

#  policy = jsonencode({
 #   Version = "2012-10-17"
#    Statement = [
 #     {
 #       Action = [
 #               "*"
 #       ]
#        Effect   = "Allow"
#        Resource = [
#                "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${var.table_name}"
 #           ]
 #     }
 #   ]
 # })

 # tags = merge(
 #   var.common_tags,
 #   {
 #     Name = "Policy to allow access to the S3 bucket"
 #   }
 # )
#}


#Textract Policy
resource "aws_iam_policy" "iampolicy_textractclient" {
  name        = "iampolicy_textractclient"
  description = "IAM policy for Lambda to access the textract"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
                 "textract:*"
        ]
        Effect   = "Allow"
        Resource = [
                "*"
            ]
      }
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name = "Policy to allow access to Textract"
    }
  )
}

#Textract Policy
resource "aws_iam_policy" "iampolicy_sns_invoke" {
  name        = "iampolicy_snsinvoke"
  description = "IAM policy for Lambda to access SNS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sns:*"
                  ]
        Effect   = "Allow"
        Resource = [
                "*"
            ]
      }
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name = "Policy to allow access to SNS"
    }
  )
}
