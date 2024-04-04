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

resource "aws_nat_gateway" "ngw" {
  count = length(var.subnets["public"].cidr_block)
  allocation_id = aws_eip.eip[count.index].id
  subnet_id     = module.subnets["public"].subnet_ids[count.index]

  tags = merge(var.tags, {Name="${var.env}-ngw-${count.index}" })
}

output "subnet_ids" {
  value = module.subnets
}