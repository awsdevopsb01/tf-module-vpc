resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags= merge(var.tags,{Name="${var.env}-vpc"})
}

module "subnets" {
  source = "./subnets"

  for_each = var.subnets
  vpc_id = aws_vpc.main.id
  cidr_block = each.value["cidr_block"]
  name = each.value["name"]
  azi=each.value["azi"]

  tags=var.tags
  env=var.env
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {Name="${var.env}-igw" })
}

resource "aws_eip" "eip" {
  count = length(var.subnets["public"].cidr_block)
  vpc=true
  tags = merge(var.tags, {Name="${var.env}-eip-${count.index}" })
}

#resource "aws_nat_gateway" "example" {
#  allocation_id = aws_eip.example.id
#  subnet_id     = aws_subnet.example.id
#
#  tags = {
#    Name = "gw NAT"
#  }
#
#  # To ensure proper ordering, it is recommended to add an explicit dependency
#  # on the Internet Gateway for the VPC.
#  depends_on = [aws_internet_gateway.example]
#}