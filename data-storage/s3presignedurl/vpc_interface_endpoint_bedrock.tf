# Create VPC Endpoint for Bedrock
resource "aws_vpc_endpoint" "bedrock" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.bedrock-runtime"
  vpc_endpoint_type = "Interface"

  subnet_ids         = var.private_subnet_ids
  security_group_ids = [aws_security_group.sg_vpce.id]

  private_dns_enabled = true

  tags = merge(
    var.common_tags,
    {
      Name = "Bedrock VPC Endpoint"
    }
  )
}