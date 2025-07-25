//Create Public Subnets
resource "aws_subnet" "dev_public_subnet" { 
  count             = var.subnet_count.public  
  vpc_id            = aws_vpc.dev_vpc.id   
  cidr_block        = var.public_subnet_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    var.common_tags,
    {
      Name = "dev_public_subnet_${count.index}"
    }
  )



}

//Create Private Subnets
resource "aws_subnet" "dev_private_subnet" {
  count             = var.subnet_count.private
  vpc_id            = aws_vpc.dev_vpc.id
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "dev_private_subnet_${count.index}"
  }
}

