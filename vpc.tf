# === VPC ===
resource "aws_vpc" "vpc" {
    cidr_block = var.vpc_cidr_blocks
    enable_dns_hostnames = true
    enable_dns_support = true
    instance_tenancy = "default"
    tags = {
        Name = var.name
    }
}

# === Public Subnet ===
resource "aws_subnet" "public_subnet1" {
    vpc_id = aws_vpc.vpc.id
    availability_zone = "ap-northeast-2a"
    cidr_block = var.public1_subnet_cidr_blocks
    map_public_ip_on_launch = false
    tags = {
        Name = "${var.name}-public-subnet-1"
    }
}

resource "aws_subnet" "public_subnet2" {
    vpc_id = aws_vpc.vpc.id
    availability_zone = "ap-northeast-2c"
    cidr_block = var.public2_subnet_cidr_blocks
    map_public_ip_on_launch = false
    tags = {
        Name= "${var.name}-public-subnet-2"
    }
}

# === Private Subnet ===
resource "aws_subnet" "private_subnet1" {
    vpc_id = aws_vpc.vpc.id
    availability_zone = "ap-northeast-2a"
    cidr_block = var.private1_subnet_cidr_blocks
    tags = {
        Name = "${var.name}-private-subnet-1"
    }
}

resource "aws_subnet" "private_subnet2" {
    vpc_id = aws_vpc.vpc.id
    availability_zone = "ap-northeast-2c"
    cidr_block = var.private2_subnet_cidr_blocks
    tags = {
        Name = "${var.name}-private-subnet-2"
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
    subnet_id = aws_subnet.public_subnet1.id
    tags = {
        "Name": var.name
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
resource "aws_route_table_association" "public_subnet1" {
  subnet_id = aws_subnet.public_subnet1.id
  route_table_id = aws_vpc.vpc.default_route_table_id
}

resource "aws_route_table_association" "public_subnet2" {
  subnet_id = aws_subnet.public_subnet2.id
  route_table_id = aws_vpc.vpc.default_route_table_id
}

resource "aws_route_table_association" "private_subnet1" {
  subnet_id = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_subnet2" {
  subnet_id = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.private.id
}

# === Route ===
resource "aws_route" "public" {
    route_table_id = aws_vpc.vpc.main_route_table_id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
}

resource "aws_route" "private" {
    route_table_id = aws_route_table.private.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
}
