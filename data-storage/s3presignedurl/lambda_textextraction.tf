data "archive_file" "lambda_textextraction_zip" {
  type = "zip"
source_dir  = "${path.module}/lambdas/textextraction/"
output_path = "${path.module}/lambdas/textextraction.zip"
}

resource "aws_lambda_function" "lambda_textextraction" {
  function_name = "textextraction"
  role          = aws_iam_role.iamrole_fullaccess.arn
  handler       = "index.handler"
  runtime       = var.python_version
  filename         = data.archive_file.lambda_textextraction_zip.output_path
  source_code_hash = data.archive_file.lambda_textextraction_zip.output_base64sha256
  #This Lambda might need more time as it is doing text extraction
  # 180 = 3 minutes
  timeout = 180
  memory_size = 1024

  vpc_config {
    subnet_ids = var.private_subnet_ids
    security_group_ids = [
      #Lambda Security Group
      aws_security_group.sg_lambda.id
    ]
  }

  tags = merge(
    var.common_tags,
    {
      Name = "Front end lambda"
    }
  )

  #As a simple lambda you do not actually need access to these variables as you do not access RDS in this Lambda
  environment {
    variables = {
      S3BUCKETNAME = var.bucket_name,
      REGION = var.aws_region,
      CLOUDFRONTDISTRIBUTION = "https://${module.cloud_front.cloudfront_distribution_domain_name}/",
      TEXTRACT_ROLE_ARN = "${aws_iam_role.iamrole_fullaccess.arn}",
      TEXTRACT_NOTIFICATION_TOPIC = "${aws_sns_topic.textract_topic.arn}",


    }
  }
}

