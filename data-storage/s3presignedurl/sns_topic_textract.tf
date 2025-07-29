resource "aws_sns_topic" "textract_topic" {
     name = "AmazonTextractCompletionTopic"
}

resource "aws_sns_topic_subscription" "lambda_subscription" {
  topic_arn = aws_sns_topic.textract_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.lambda_textractsubscriber.arn
}

resource "aws_lambda_permission" "sns_permission" {
  statement_id  = "AllowSnsTopicToInvokeLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_textractsubscriber.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.textract_topic.arn
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.textract_topic.arn
  protocol  = "email"
  endpoint  = "youremail@yourcompany.com" # Replace with the desired email address
}