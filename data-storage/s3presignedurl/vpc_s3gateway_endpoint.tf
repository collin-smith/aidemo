# Create VPC S3 Gateway Endpoint for S3
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  route_table_ids   = [var.privateroutetableid]
  vpc_endpoint_type = "Gateway"

  policy = <<POLICY
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "*",
      "Effect": "Allow",
      "Resource": [
                "arn:aws:s3:::${var.bucket_name}",
                "arn:aws:s3:::${var.bucket_name}/*"
            ],
      "Principal": "*"
    }
  ]
}
POLICY

  tags = merge(
    var.common_tags,
    {
      Name = "S3 Gateway Endpoint"
    }
  )
}

resource "aws_vpc_endpoint_route_table_association" "gatewayendpoints" {
  route_table_id  = var.privateroutetableid
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}