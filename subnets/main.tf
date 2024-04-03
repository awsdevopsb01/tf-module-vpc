resource "aws_subnet" "main" {
  count = length(var.cidr_block)
  vpc_id     = var.vpc_id
  cidr_block = var.cidr_block[count.index]
  availability_zone = var.azi[count.index]

  tags = merge(var.tags, {Name="${var.env}-${var.name}-subnet-${count.index}"})

}

resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id

  tags = merge(var.tags, {Name="${var.env}-${var.name}-igw-${count.index}"})
}