### SECURITY GROUP PARA HTTP ###
resource "aws_security_group" "carlosgb-SG-HTTP" {
  description = "Permitir acceso HTTP en el puerto 80"
  vpc_id      = aws_vpc.carlosVPC.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name    = "carlosgb-SG-HTTP"
    Project = "laboratorio 4"
    Owner   = "carlosgb"
  }
}

### SECURITY GROUP PARA HTTPS ###
resource "aws_security_group" "carlosgb-SG-HTTPS" {
  description = "Permitir acceso a HTTPS puerto 443"
  vpc_id      = aws_vpc.carlosVPC.id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name    = "carlosgb-SG-HTTPS"
    Project = "laboratorio 4"
    Owner   = "carlosgb"
  }
}

### SECURITY GROUP PARA SSH ###
resource "aws_security_group" "carlosgb-SG-SSH" {
  description = "Permitir acceso por el puerto 22"
  vpc_id      = aws_vpc.carlosVPC.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name    = "carlosgb-SG-SSH"
    Project = "laboratorio 4"
    Owner   = "carlosgb"
  }
}

### SECURITY GROUP PARA BBDD POSTGRESQL ###
resource "aws_security_group" "carlosgb-SG-POSTGRESQL" {
  description = "Permitir acceso a PostgreSQL en el puerto 5432"
  vpc_id      = aws_vpc.carlosVPC.id
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name    = "carlosgb-SG-POSTGRESQL"
    Project = "laboratorio 4"
    Owner   = "carlosgb"
  }
}

### SECURITY GROUP PARA CACHE REDIS ###
resource "aws_security_group" "carlosgb-SG-REDIS" {
  description = "Permitir acceso a cache Redis en el puerto 6379"
  vpc_id      = aws_vpc.carlosVPC.id
  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name    = "carlosgb-SG-REDIS"
    Project = "laboratorio 4"
    Owner   = "carlosgb"
  }
}

### SECURITY GROUP PARA CACHE MEMCACHE ###
resource "aws_security_group" "carlosgb-SG-MEMCACHE" {
  description = "Permitir acceso a cache Memcache en el puerto 11211"
  vpc_id      = aws_vpc.carlosVPC.id
  ingress {
    from_port   = 11211
    to_port     = 11211
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name    = "carlosgb-SG-MEMCACHE"
    Project = "laboratorio 4"
    Owner   = "carlosgb"
  }
}

### SECURITY GROUP PARA EFS ###
resource "aws_security_group" "carlosgb-SG-EFS" {
  description = "Permitir acceso a EFS en el puerto 2049"
  vpc_id      = aws_vpc.carlosVPC.id
  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name    = "carlosgb-SG-EFS"
    Project = "laboratorio 4"
    Owner   = "carlosgb"
  }
}



