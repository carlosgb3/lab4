###  CREAMOS LA VPC  ###
resource "aws_vpc" "carlosVPC" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name    = "carlosgb-VPC"
    Project = "laboratorio 4"
    Owner   = "carlosgb"
  }
}


### CREAMOS LAS 4 SUBNETS ### 
resource "aws_subnet" "subnet-public-1" {
  vpc_id            = aws_vpc.carlosVPC.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name    = "carlosgb-subnet-public-1"
    Project = "laboratorio 4"
    Owner   = "carlosgb"
  }
}

resource "aws_subnet" "subnet-private-11" {
  vpc_id            = aws_vpc.carlosVPC.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name    = "carlosgb-Subnet-private-11"
    Project = "laboratorio 4"
    Owner   = "carlosgb"
  }
}

resource "aws_subnet" "subnet-public-2" {
  vpc_id            = aws_vpc.carlosVPC.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name    = "carlosgb-Subnet-public-2"
    Project = "laboratorio 4"
    Owner   = "carlosgb"
  }
}

resource "aws_subnet" "subnet-private-22" {
  vpc_id            = aws_vpc.carlosVPC.id
  cidr_block        = "10.0.22.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name    = "carlosgb-Subnet-private-22"
    Project = "laboratorio 4"
    Owner   = "carlosgb"
  }
}

### CREAMOS EL INTERNET GATEWAY Y LO ATACHAMOS A LA VPC ### 
resource "aws_internet_gateway" "IGW-lab" {
  vpc_id = aws_vpc.carlosVPC.id
  tags = {
    Name    = "carlosgb-IGW"
    Project = "laboratorio 4"
    Owner   = "carlosgb"
  }
}

### CREAMOS UNA ELASTIC IP Y SE LA ATACHAMOS AL NAT GATEWAY ###
resource "aws_eip" "nat-eip" {
  domain = "vpc"
  tags = {
    Name    = "carlosgb-EIP"
    Project = "laboratorio 4"
    Owner   = "carlosgb"
  }
}

resource "aws_nat_gateway" "carlosgb-nat" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id     = aws_subnet.subnet-public-1.id
  tags = {
    Name    = "carlosgb-NAT"
    Project = "laboratorio 4"
    Owner   = "carlosgb"
  }
}

### CREAMOS LAS ROUTING TABLES Y SE LAS ATACHAMOS A LAS SUBREDES ###
resource "aws_route_table" "carlosgb-RT-public" {
  vpc_id = aws_vpc.carlosVPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW-lab.id
  }
  tags = {
    Name    = "carlosgb-RT-public"
    Project = "laboratorio 4"
    Owner   = "carlosgb"
  }
}

resource "aws_route_table" "carlosgb-RT-private" {
  vpc_id = aws_vpc.carlosVPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.carlosgb-nat.id
  }
  tags = {
    Name    = "carlosgb-RT-private"
    Project = "laboratorio 4"
    Owner   = "carlosgb"
  }
}

resource "aws_route_table_association" "subnet_a_association" {
  subnet_id      = aws_subnet.subnet-public-1.id
  route_table_id = aws_route_table.carlosgb-RT-public.id
}

resource "aws_route_table_association" "subnet_b_association" {
  subnet_id      = aws_subnet.subnet-public-2.id
  route_table_id = aws_route_table.carlosgb-RT-public.id
}

resource "aws_route_table_association" "subnet_c_association" {
  subnet_id      = aws_subnet.subnet-private-11.id
  route_table_id = aws_route_table.carlosgb-RT-private.id
}

resource "aws_route_table_association" "subnet_d_association" {
  subnet_id      = aws_subnet.subnet-private-22.id
  route_table_id = aws_route_table.carlosgb-RT-private.id
}