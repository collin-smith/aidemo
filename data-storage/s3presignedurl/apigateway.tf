# API Gateway REST API
resource "aws_api_gateway_rest_api" "poc_api" {
  name        = "POC Objects API"
  description = "API Gateway for POC Objects API"
}

# ENDPOINT objects
# API Gateway Resource (Endpoint)
resource "aws_api_gateway_resource" "objects" {
  rest_api_id = aws_api_gateway_rest_api.poc_api.id
  parent_id   = aws_api_gateway_rest_api.poc_api.root_resource_id
  path_part   = "objects" 
}

# API Gateway Method
resource "aws_api_gateway_method" "objects" {
  rest_api_id   = aws_api_gateway_rest_api.poc_api.id
  resource_id   = aws_api_gateway_resource.objects.id #
  http_method   = "ANY" #
  authorization = "NONE"
}
# API Gateway Integration
resource "aws_api_gateway_integration" "objects" {
  rest_api_id = aws_api_gateway_rest_api.poc_api.id
  resource_id = aws_api_gateway_resource.objects.id #
  http_method = aws_api_gateway_method.objects.http_method #
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri = aws_lambda_function.lambda_objects.invoke_arn
}
# Lambda permission
resource "aws_lambda_permission" "objects" {
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_objects.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.poc_api.execution_arn}/*/*"
}

#CORS  (This is tied to the specific resource)
resource "aws_api_gateway_method" "cors_options_objects" {
  rest_api_id = aws_api_gateway_rest_api.poc_api.id
  resource_id   = aws_api_gateway_resource.objects.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

#(This is tied to the specific resource)
resource "aws_api_gateway_integration" "cors_integration_objects" {
  rest_api_id = aws_api_gateway_rest_api.poc_api.id
  resource_id   = aws_api_gateway_resource.objects.id
  http_method = aws_api_gateway_method.cors_options_objects.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration_response" "cors_integration_response_objects" {
  rest_api_id   = aws_api_gateway_rest_api.poc_api.id
  resource_id   = aws_api_gateway_resource.objects.id #
  http_method = aws_api_gateway_method.cors_options_objects.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT,DELETE'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  #Add the cors after the aws_api_gateway_integration non-get functions are created (POST, PUT, DELETE)
  depends_on = [
    aws_api_gateway_integration.objects
  ]

}

resource "aws_api_gateway_method_response" "cors_method_response_objects" {
  rest_api_id = aws_api_gateway_rest_api.poc_api.id
  resource_id   = aws_api_gateway_resource.objects.id
  http_method = aws_api_gateway_method.cors_options_objects.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}



# ENDPOINT getpresignedUrl(POST)
# API Gateway Resource (Endpoint)
resource "aws_api_gateway_resource" "presignedurl" {
  rest_api_id = aws_api_gateway_rest_api.poc_api.id
  parent_id   = aws_api_gateway_rest_api.poc_api.root_resource_id
  path_part   = "presignedurl" 
}

#CORS  (Make sure that they are all configured properly, watch out for the suffixes etc.)
#########################################
resource "aws_api_gateway_method" "cors_options_presignedurl" {
  rest_api_id = aws_api_gateway_rest_api.poc_api.id
  resource_id   = aws_api_gateway_resource.presignedurl.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "cors_integration_presignedurl" {
  rest_api_id = aws_api_gateway_rest_api.poc_api.id
  resource_id   = aws_api_gateway_resource.presignedurl.id
  http_method = aws_api_gateway_method.cors_options_presignedurl.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration_response" "cors_integration_response_presignedurl" {
  rest_api_id   = aws_api_gateway_rest_api.poc_api.id
  resource_id   = aws_api_gateway_resource.presignedurl.id #
  http_method = aws_api_gateway_method.cors_options_presignedurl.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT,DELETE'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  #Add the cors after the aws_api_gateway_integration non-get functions are created (POST, PUT, DELETE)
  depends_on = [
    aws_api_gateway_integration.presignedurl
  ]

}

resource "aws_api_gateway_method_response" "cors_method_response_presignedurl" {
  rest_api_id = aws_api_gateway_rest_api.poc_api.id
  resource_id   = aws_api_gateway_resource.presignedurl.id
  http_method = aws_api_gateway_method.cors_options_presignedurl.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

# API Gateway Method
resource "aws_api_gateway_method" "presignedurl" {
  rest_api_id = aws_api_gateway_rest_api.poc_api.id
  resource_id   = aws_api_gateway_resource.presignedurl.id #
  http_method   = "POST" #
  authorization = "NONE"
}
# API Gateway Integration
resource "aws_api_gateway_integration" "presignedurl" {
  rest_api_id = aws_api_gateway_rest_api.poc_api.id
  resource_id   = aws_api_gateway_resource.presignedurl.id
  http_method = aws_api_gateway_method.presignedurl.http_method #
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri = aws_lambda_function.lambda_presignedurl.invoke_arn

}
# Lambda permission
resource "aws_lambda_permission" "presignedurl" {
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_presignedurl.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.poc_api.execution_arn}/*/*"
}


# ENDPOINT prompt(POST)
# API Gateway Resource (Endpoint)
resource "aws_api_gateway_resource" "prompt" {
  rest_api_id = aws_api_gateway_rest_api.poc_api.id
  parent_id   = aws_api_gateway_rest_api.poc_api.root_resource_id
  path_part   = "prompt" 
}

#CORS  (Make sure that they are all configured properly, watch out for the suffixes etc.)
#########################################
resource "aws_api_gateway_method" "cors_options_prompt" {
  rest_api_id = aws_api_gateway_rest_api.poc_api.id
  resource_id   = aws_api_gateway_resource.prompt.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "cors_integration_prompt" {
  rest_api_id = aws_api_gateway_rest_api.poc_api.id
  resource_id   = aws_api_gateway_resource.prompt.id
  http_method = aws_api_gateway_method.cors_options_prompt.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration_response" "cors_integration_response_prompt" {
  rest_api_id   = aws_api_gateway_rest_api.poc_api.id
  resource_id   = aws_api_gateway_resource.prompt.id #
  http_method = aws_api_gateway_method.cors_options_prompt.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT,DELETE'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  #Add the cors after the aws_api_gateway_integration non-get functions are created (POST, PUT, DELETE)
  depends_on = [
    aws_api_gateway_integration.prompt
  ]

}

resource "aws_api_gateway_method_response" "cors_method_response_prompt" {
  rest_api_id = aws_api_gateway_rest_api.poc_api.id
  resource_id   = aws_api_gateway_resource.prompt.id
  http_method = aws_api_gateway_method.cors_options_prompt.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

# API Gateway Method
resource "aws_api_gateway_method" "prompt" {
  rest_api_id = aws_api_gateway_rest_api.poc_api.id
  resource_id   = aws_api_gateway_resource.prompt.id #
  http_method   = "POST" #
  authorization = "NONE"
}
# API Gateway Integration
resource "aws_api_gateway_integration" "prompt" {
  rest_api_id = aws_api_gateway_rest_api.poc_api.id
  resource_id   = aws_api_gateway_resource.prompt.id
  http_method = aws_api_gateway_method.prompt.http_method #
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri = aws_lambda_function.lambda_prompt.invoke_arn

}
# Lambda permission
resource "aws_lambda_permission" "prompt" {
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_prompt.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.poc_api.execution_arn}/*/*"
}


# ENDPOINT imageanalysis(POST)
# API Gateway Resource (Endpoint)
resource "aws_api_gateway_resource" "imageanalysis" {
  rest_api_id = aws_api_gateway_rest_api.poc_api.id
  parent_id   = aws_api_gateway_rest_api.poc_api.root_resource_id
  path_part   = "imageanalysis" 
}

#CORS  (Make sure that they are all configured properly, watch out for the suffixes etc.)
#########################################
resource "aws_api_gateway_method" "cors_options_imageanalysis" {
  rest_api_id = aws_api_gateway_rest_api.poc_api.id
  resource_id   = aws_api_gateway_resource.imageanalysis.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "cors_integration_imageanalysis" {
  rest_api_id = aws_api_gateway_rest_api.poc_api.id
  resource_id   = aws_api_gateway_resource.imageanalysis.id
  http_method = aws_api_gateway_method.cors_options_imageanalysis.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration_response" "cors_integration_response_imageanalysis" {
  rest_api_id   = aws_api_gateway_rest_api.poc_api.id
  resource_id   = aws_api_gateway_resource.imageanalysis.id #
  http_method = aws_api_gateway_method.cors_options_imageanalysis.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT,DELETE'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  #Add the cors after the aws_api_gateway_integration non-get functions are created (POST, PUT, DELETE)
  depends_on = [
    aws_api_gateway_integration.imageanalysis
  ]

}

resource "aws_api_gateway_method_response" "cors_method_response_imageanalysis" {
  rest_api_id = aws_api_gateway_rest_api.poc_api.id
  resource_id   = aws_api_gateway_resource.imageanalysis.id
  http_method = aws_api_gateway_method.cors_options_imageanalysis.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

# API Gateway Method
resource "aws_api_gateway_method" "imageanalysis" {
  rest_api_id = aws_api_gateway_rest_api.poc_api.id
  resource_id   = aws_api_gateway_resource.imageanalysis.id #
  http_method   = "POST" #
  authorization = "NONE"
}
# API Gateway Integration
resource "aws_api_gateway_integration" "imageanalysis" {
  rest_api_id = aws_api_gateway_rest_api.poc_api.id
  resource_id   = aws_api_gateway_resource.imageanalysis.id
  http_method = aws_api_gateway_method.imageanalysis.http_method #
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri = aws_lambda_function.lambda_imageanalysis.invoke_arn

}
# Lambda permission
resource "aws_lambda_permission" "imageanalysis" {
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_imageanalysis.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.poc_api.execution_arn}/*/*"
}


# ENDPOINT imagegeneration(POST)
# API Gateway Resource (Endpoint)
resource "aws_api_gateway_resource" "imagegeneration" {
  rest_api_id = aws_api_gateway_rest_api.poc_api.id
  parent_id   = aws_api_gateway_rest_api.poc_api.root_resource_id
  path_part   = "imagegeneration" 
}

#CORS  (Make sure that they are all configured properly, watch out for the suffixes etc.)
#########################################
resource "aws_api_gateway_method" "cors_options_imagegeneration" {
  rest_api_id = aws_api_gateway_rest_api.poc_api.id
  resource_id   = aws_api_gateway_resource.imagegeneration.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "cors_integration_imagegeneration" {
  rest_api_id = aws_api_gateway_rest_api.poc_api.id
  resource_id   = aws_api_gateway_resource.imagegeneration.id
  http_method = aws_api_gateway_method.cors_options_imagegeneration.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration_response" "cors_integration_response_imagegeneration" {
  rest_api_id   = aws_api_gateway_rest_api.poc_api.id
  resource_id   = aws_api_gateway_resource.imagegeneration.id #
  http_method = aws_api_gateway_method.cors_options_imagegeneration.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT,DELETE'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  #Add the cors after the aws_api_gateway_integration non-get functions are created (POST, PUT, DELETE)
  depends_on = [
    aws_api_gateway_integration.imagegeneration
  ]

}

resource "aws_api_gateway_method_response" "cors_method_response_imagegeneration" {
  rest_api_id = aws_api_gateway_rest_api.poc_api.id
  resource_id   = aws_api_gateway_resource.imagegeneration.id
  http_method = aws_api_gateway_method.cors_options_imagegeneration.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

# API Gateway Method
resource "aws_api_gateway_method" "imagegeneration" {
  rest_api_id = aws_api_gateway_rest_api.poc_api.id
  resource_id   = aws_api_gateway_resource.imagegeneration.id #
  http_method   = "POST" #
  authorization = "NONE"
}
# API Gateway Integration
resource "aws_api_gateway_integration" "imagegeneration" {
  rest_api_id = aws_api_gateway_rest_api.poc_api.id
  resource_id   = aws_api_gateway_resource.imagegeneration.id
  http_method = aws_api_gateway_method.imagegeneration.http_method #
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri = aws_lambda_function.lambda_imagegeneration.invoke_arn

}
# Lambda permission
resource "aws_lambda_permission" "imagegeneration" {
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_imagegeneration.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.poc_api.execution_arn}/*/*"
}

# ENDPOINT documentanalysis(POST)
# API Gateway Resource (Endpoint)
resource "aws_api_gateway_resource" "documentanalysis" {
  rest_api_id = aws_api_gateway_rest_api.poc_api.id
  parent_id   = aws_api_gateway_rest_api.poc_api.root_resource_id
  path_part   = "documentanalysis" 
}

#CORS  (Make sure that they are all configured properly, watch out for the suffixes etc.)
#########################################
resource "aws_api_gateway_method" "cors_options_documentanalysis" {
  rest_api_id = aws_api_gateway_rest_api.poc_api.id
  resource_id   = aws_api_gateway_resource.documentanalysis.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "cors_integration_documentanalysis" {
  rest_api_id = aws_api_gateway_rest_api.poc_api.id
  resource_id   = aws_api_gateway_resource.documentanalysis.id
  http_method = aws_api_gateway_method.cors_options_documentanalysis.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration_response" "cors_integration_response_documentanalysis" {
  rest_api_id   = aws_api_gateway_rest_api.poc_api.id
  resource_id   = aws_api_gateway_resource.documentanalysis.id #
  http_method = aws_api_gateway_method.cors_options_documentanalysis.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT,DELETE'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  #Add the cors after the aws_api_gateway_integration non-get functions are created (POST, PUT, DELETE)
  depends_on = [
    aws_api_gateway_integration.documentanalysis
  ]

}

resource "aws_api_gateway_method_response" "cors_method_response_documentanalysis" {
  rest_api_id = aws_api_gateway_rest_api.poc_api.id
  resource_id   = aws_api_gateway_resource.documentanalysis.id
  http_method = aws_api_gateway_method.cors_options_documentanalysis.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

# API Gateway Method
resource "aws_api_gateway_method" "documentanalysis" {
  rest_api_id = aws_api_gateway_rest_api.poc_api.id
  resource_id   = aws_api_gateway_resource.documentanalysis.id #
  http_method   = "POST" #
  authorization = "NONE"
}
# API Gateway Integration
resource "aws_api_gateway_integration" "documentanalysis" {
  rest_api_id = aws_api_gateway_rest_api.poc_api.id
  resource_id   = aws_api_gateway_resource.documentanalysis.id
  http_method = aws_api_gateway_method.documentanalysis.http_method #
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri = aws_lambda_function.lambda_documentanalysis.invoke_arn

}
# Lambda permission
resource "aws_lambda_permission" "documentanalysis" {
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_documentanalysis.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.poc_api.execution_arn}/*/*"
}

# ENDPOINT documentanalysis(POST)
# API Gateway Resource (Endpoint)
resource "aws_api_gateway_resource" "documentanalysisllm" {
  rest_api_id = aws_api_gateway_rest_api.poc_api.id
  parent_id   = aws_api_gateway_rest_api.poc_api.root_resource_id
  path_part   = "documentanalysisllm" 
}

#CORS  (Make sure that they are all configured properly, watch out for the suffixes etc.)
#########################################
resource "aws_api_gateway_method" "cors_options_documentanalysisllm" {
  rest_api_id = aws_api_gateway_rest_api.poc_api.id
  resource_id   = aws_api_gateway_resource.documentanalysisllm.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "cors_integration_documentanalysisllm" {
  rest_api_id = aws_api_gateway_rest_api.poc_api.id
  resource_id   = aws_api_gateway_resource.documentanalysisllm.id
  http_method = aws_api_gateway_method.cors_options_documentanalysisllm.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration_response" "cors_integration_response_documentanalysisllm" {
  rest_api_id   = aws_api_gateway_rest_api.poc_api.id
  resource_id   = aws_api_gateway_resource.documentanalysisllm.id #
  http_method = aws_api_gateway_method.cors_options_documentanalysisllm.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT,DELETE'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  #Add the cors after the aws_api_gateway_integration non-get functions are created (POST, PUT, DELETE)
  depends_on = [
    aws_api_gateway_integration.documentanalysisllm
  ]

}

resource "aws_api_gateway_method_response" "cors_method_response_documentanalysisllm" {
  rest_api_id = aws_api_gateway_rest_api.poc_api.id
  resource_id   = aws_api_gateway_resource.documentanalysisllm.id
  http_method = aws_api_gateway_method.cors_options_documentanalysisllm.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

# API Gateway Method
resource "aws_api_gateway_method" "documentanalysisllm" {
  rest_api_id = aws_api_gateway_rest_api.poc_api.id
  resource_id   = aws_api_gateway_resource.documentanalysisllm.id #
  http_method   = "POST" #
  authorization = "NONE"
}
# API Gateway Integration
resource "aws_api_gateway_integration" "documentanalysisllm" {
  rest_api_id = aws_api_gateway_rest_api.poc_api.id
  resource_id   = aws_api_gateway_resource.documentanalysisllm.id
  http_method = aws_api_gateway_method.documentanalysisllm.http_method #
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri = aws_lambda_function.lambda_documentanalysisllm.invoke_arn

}
# Lambda permission
resource "aws_lambda_permission" "documentanalysisllm" {
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_documentanalysisllm.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.poc_api.execution_arn}/*/*"
}


# Deploy API Gateway Deployment
resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [
    aws_api_gateway_integration.objects,
    aws_api_gateway_integration.presignedurl,
    aws_api_gateway_integration.prompt,
    aws_api_gateway_integration.imageanalysis,
    aws_api_gateway_integration.imagegeneration,
    aws_api_gateway_integration.documentanalysis,
    aws_api_gateway_integration.documentanalysisllm
      ]
  rest_api_id = aws_api_gateway_rest_api.poc_api.id
}

resource "aws_api_gateway_stage" "api_deployment" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.poc_api.id
  stage_name    = "prod"
}