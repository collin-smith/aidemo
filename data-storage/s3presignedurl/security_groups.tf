#Security Group for VPC Endpoints
resource "aws_security_group" "sg_vpce" {
  name        = "sg_vpce"
  description = "Security group for vpc_endpoint to S3"
  vpc_id      = var.vpc_id

  # Ingress Rules
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
    description = "Allow HTTPS inbound from the VPC itself"
  }

#Tighten this up to be the S3 address
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr_block]
  }

  tags = merge(
    var.common_tags,
    {
      Name = "sg_vpce"
    }
  )
}

resource "aws_security_group" "sg_lambda" {
  name        = "sg_lambda"
  description = "Security group for lambdas"
  vpc_id      = var.vpc_id


  #This is to allow traffic to the Lambdas
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "sg_lambda"
  }
}

