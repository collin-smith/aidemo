output "A_sourcefiles" {
  value = "${var.sourcefiles}"
}

output "B_cloudfront_distribution_domain_name" {
  value = "http://${module.cloud_front.cloudfront_distribution_domain_name}"
}