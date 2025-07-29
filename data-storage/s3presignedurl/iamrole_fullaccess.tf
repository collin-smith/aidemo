#Role Bedrock Access Role (See policies for the permissions granted)

resource "aws_iam_role" "iamrole_fullaccess" {
  name = "iamrole_fullaccess"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
          "lambda.amazonaws.com",
          "textract.amazonaws.com"
        ]
        }
      }
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name = "Full access role for Lambdas for multiple services"
    }
  )
}


#Attaching a policy(permissions) to an IAM role
#Provides minimum permissions for a Lambda function to execute while accessing a resource within a VPC - create, describe, delete network interfaces and write permissions to CloudWatch Logs.
resource "aws_iam_role_policy_attachment" "iampolicyattachment_fullaccess_vpcaccess" {
  role       = aws_iam_role.iamrole_fullaccess.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

#Attaching a policy(permissions) to an IAM role
#Provides access to Bedrock
resource "aws_iam_role_policy_attachment" "iampolicyattachment_fullaccess_bedrock" {
  role       = aws_iam_role.iamrole_fullaccess.name
  policy_arn = aws_iam_policy.iampolicy_bedrockclient.arn
}

#Attaching a policy(permissions) to an IAM role
#Provides access to S3
resource "aws_iam_role_policy_attachment" "iampolicyattachment_fullaccess_s3" {
  role       = aws_iam_role.iamrole_fullaccess.name
  policy_arn = aws_iam_policy.iampolicy_s3client.arn
}

#Attaching a policy(permissions) to an IAM role
#Provides access to Textract
resource "aws_iam_role_policy_attachment" "iampolicyattachment_fullaccess_textract" {
  role       = aws_iam_role.iamrole_fullaccess.name
  policy_arn = aws_iam_policy.iampolicy_textractclient.arn
}

#Attaching a policy(permissions) to an IAM role
#Provides access to SNS
resource "aws_iam_role_policy_attachment" "iampolicyattachment_fullaccess_snsninvoke" {
  role       = aws_iam_role.iamrole_fullaccess.name
  policy_arn = aws_iam_policy.iampolicy_sns_invoke.arn
}


