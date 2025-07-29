output "A_sourcefiles" {
  value = "${var.sourcefiles}"
}

output "B_s3_bucketname" {
  value = "${var.bucket_name}"
}

output "C_cloudfront_distribution_domain_name" {
  value = "https://${module.cloud_front.cloudfront_distribution_domain_name}/"
}

output "D_base_url" {
  description = "API Gateway URL"
  value = "${aws_api_gateway_stage.api_deployment.invoke_url}/}"
}

output "E_gets3objects_GET" {
  description = "Get S3 objects Lambda URL"
  value = "GET ${aws_api_gateway_stage.api_deployment.invoke_url}/${aws_api_gateway_resource.objects.path_part}"
}

output "F_deletes3objects_POST" {
  description = "DELETE S3 objects Lambda URL"
  value = "DELETE ${aws_api_gateway_stage.api_deployment.invoke_url}/${aws_api_gateway_resource.objects.path_part}"
}

output "G_presignedurl_POST" {
  description = "Presigned Url Lambda URL"
  value = "POST (with body) ${aws_api_gateway_stage.api_deployment.invoke_url}/${aws_api_gateway_resource.presignedurl.path_part}"
}

output "H_prompt_POST" {
  description = "Prompt Lambda URL"
  value = "POST (with body) ${aws_api_gateway_stage.api_deployment.invoke_url}/${aws_api_gateway_resource.prompt.path_part}"
}

output "I_imageanalysis_POST" {
  description = "Image Analysis Lambda URL"
  value = "POST (with body) ${aws_api_gateway_stage.api_deployment.invoke_url}/${aws_api_gateway_resource.imageanalysis.path_part}"
}

output "J_imagegeneration_POST" {
  description = "Image Generation Lambda URL"
  value = "POST (with body) ${aws_api_gateway_stage.api_deployment.invoke_url}/${aws_api_gateway_resource.imagegeneration.path_part}"
}

output "K_documentanalysis_POST" {
  description = "Document Analysis Lambda URL"
  value = "POST (with body) ${aws_api_gateway_stage.api_deployment.invoke_url}/${aws_api_gateway_resource.documentanalysis.path_part}"
}

output "K_documentanalysisllm_POST" {
  description = "Document Analysis LLM Lambda URL"
  value = "POST (with body) ${aws_api_gateway_stage.api_deployment.invoke_url}/${aws_api_gateway_resource.documentanalysisllm.path_part}"
}


