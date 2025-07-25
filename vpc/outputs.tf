output "A_aws_region" {
  value       = var.aws_region
  description = "VPC id"
}

output "B_VPC_Id" {
  value       = aws_vpc.dev_vpc.id
  description = "VPC id"
}

output "C_VPC_Arn" {
  value       = aws_vpc.dev_vpc.arn
  description = "VPC arn"
}

output "D_VPC_cidr_block" {
  value       = aws_vpc.dev_vpc.cidr_block
  description = "VPC Cidr Block"
}

output "E_Public_Subnet_Ids" {
value = aws_subnet.dev_public_subnet[*].id
description ="Public subnet ids"
}

output "F_Public_RouteTable_Id" {
value = aws_route_table.dev_public_rt.id
description ="Public Route Table ID"
}

output "G_Private_Subnet_Ids" {
value = aws_subnet.dev_private_subnet[*].id
description ="Private subnet ids"
}

output "H_Private_RouteTable_Id" {
value = aws_route_table.dev_private_rt.id
description ="Private Route Table ID"
}






