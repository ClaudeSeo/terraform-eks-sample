# === VPC ===
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_blocks
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  tags = {
    Name = var.name
  }
}

# === Public Subnet ===
resource "aws_subnet" "public_subnet" {
  count = 2

  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = var.available_az[count.index]
  cidr_block              = var.public_cidr_blocks[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name                                = "${var.name}-public-subnet-${count.index}"
    "kubernetes.io/cluster/${var.name}" = "shared"
  }
}

# === Private Subnet ===
resource "aws_subnet" "private_subnet" {
  count = 2

  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.available_az[count.index]
  cidr_block        = var.private_cidr_blocks[count.index]
  tags = {
    Name                                = "${var.name}-private-subnet-${count.index}"
    "kubernetes.io/cluster/${var.name}" = "shared"
  }
}

# === Internet Gateway ===
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.name}-igw"
  }
}

# === Nat Gateway ===
resource "aws_eip" "nat_eip" {
  vpc = true
  tags = {
    Name = var.name
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet[0].id
  tags = {
    "Name" : var.name
  }
}

# === Route Table ===
resource "aws_default_route_table" "public" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id
  tags = {
    Name = "${var.name}-public"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.name}-private"
  }
}

# === Route Table Association ===
resource "aws_route_table_association" "public_subnet" {
  count          = 2
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_vpc.vpc.default_route_table_id
}

resource "aws_route_table_association" "private_subnet" {
  count          = 2
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private.id
}

# === Route ===
resource "aws_route" "public" {
  route_table_id         = aws_vpc.vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}
