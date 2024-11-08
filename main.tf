terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.0"
    }
  }
  /*
  backend "s3" {
    bucket         = "carlosgb-s3-terraform"
    key            = "terraform/terraform.fstate"
    region         = "us-east-1"
    dynamodb_table = "carlosgb-lab04-lock"
    encrypt        = true
  }
  */
}


/*
    EL BAKCEND DE S3 SE QUEDA DESACITIVADO
    Y LOCK DE DYNAMO DB PARA LANZAR EN LOCAL
    ----EXPORTAR LOS LOGS---
*/

### CREAMOS UNA POLICY Y UN ROL PARA SSM Y SE LA ATACHAMOS ###
resource "aws_iam_role" "ssm_role" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
  tags = {
    Name    = "SSMRole"
    Project = "laboratorio 4"
    Owner   = "carlosgb"
  }
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "SSMInstanceProfile"
  role = aws_iam_role.ssm_role.name
}




### CREAMOS LA DB DE POSTGRESQL ###
resource "aws_db_instance" "carlosgb-DB-postgresql" {
  identifier             = "postgres-db"
  allocated_storage      = 20 
  engine                 = "postgres"
  engine_version         = "16.3"
  instance_class         = "db.t3.micro"
  username               = "postgres"
  password               = "carlosgb"
  publicly_accessible    = false
  skip_final_snapshot    = true
  db_name                = "wordpress"
  multi_az               = true
  vpc_security_group_ids = [aws_security_group.carlosgb-SG-POSTGRESQL.id]
  db_subnet_group_name   = aws_db_subnet_group.grupo-subnet-privadas.name
  tags = {
    Name    = "carlosgb-DB-PostgreSQL"
    Project = "laboratorio 4"
    Owner   = "carlosgb"
  }
}

### CREAMOS LOS SUBNETS GROUP PARA LA DB ###
resource "aws_db_subnet_group" "grupo-subnet-privadas" {
  name       = "rds_subnet_group"
  subnet_ids = [aws_subnet.subnet-private-11.id, aws_subnet.subnet-private-22.id]
  tags = {
    Name    = "carlosgb-grupo-subnet-privadas"
    Project = "laboratorio 4"
    Owner   = "carlosgb"
  }
}

###  CREAR UN HOSTED ZONE PRIVADO EN ROUTE53  ###
resource "aws_route53_zone" "carlosgb-private-host" {
  name = "carlosgb.local"
  vpc {
    vpc_id = aws_vpc.carlosVPC.id
  }
  tags = {
    Name    = "carlosgb-private-host"
    Project = "laboratorio 4"
    Owner   = "carlosgb"
  }
}

### REGISTRO CNAME PARA LA BASE DE DATOS ###
resource "aws_route53_record" "db_record" {
  zone_id = aws_route53_zone.carlosgb-private-host.zone_id
  name    = "carlosgb-rds-db-interno"
  type    = "CNAME"
  ttl     = 300
  records = [split(":", aws_db_instance.carlosgb-DB-postgresql.endpoint)[0]]
}

### REGISTRO CNAME PARA EL ALB ###
resource "aws_route53_record" "alb_record" {
  zone_id = aws_route53_zone.carlosgb-private-host.zone_id
  name    = "carlosgb-alb-interno" 
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.carlosgb-ALB.dns_name]
}


### CREAMOS CON SECRETS MANAGER EL REGISTRO DEL PASS DE LA DB  ###
resource "aws_secretsmanager_secret" "db_password" {
  name = "wordpress-db-password-04"
}

resource "aws_secretsmanager_secret_version" "db_password_version" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    DB_PASSWORD = "carlosgb"
  })
}




### CREAMOS EL ASG ### 
### https://developer.hashicorp.com/terraform/tutorials/aws/aws-asg ###

resource "aws_lb_target_group" "carlosgb-TG" {
  name     = "carlosgb-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.carlosVPC.id
  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
    tags = {
    Name    = "carlosgb-TG"
    Project = "laboratorio 4"
    Owner   = "carlosgb"
  }
}



## CREAMOS EL LAUNCH TEMPLATE ###
resource "aws_launch_template" "carlosgb-LT" {
  name_prefix = "carlosgb-"
  //image_id        = "ami-06b21ccaeff8cd686"
  //image_id        = "ami-029c3107a777b2179"
  //image_id        = "ami-0b1c6c874f450bf26"
  //image_id        = "ami-055543b85ae1357ac"
  image_id      = "ami-085f2d70667e3f311"
  instance_type = "t2.micro"
  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.carlosgb-SG-HTTP.id]
  }

  ###  ASIGNAMOS EL ROL SSM  ###
  iam_instance_profile {
    name = aws_iam_instance_profile.ssm_instance_profile.name
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "carlosgb-instance"
      Project = "laboratorio 4"
      Owner   = "carlosgb"
    }
  }
  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum install -y amazon-efs-utils
              mkdir -p /mnt/efs
              mount -t efs ${aws_efs_file_system.example.id}:/ /mnt/efs
            EOF
  )

}

### APLICATION LOAD BALANCER ###
### CREAMOS EL CERTIFICADO SSL  ###
resource "aws_acm_certificate" "carlosgb-ssl" {
  certificate_body  = file("./certificados/carlosgb-certificado.crt")
  private_key       = file("./certificados/carlosgb-private.key")
  tags = {
    Name    = "carlosgb-SSL"
    Project = "laboratorio 4"
    Owner   = "carlosgb"
  }
}

## CREAMOS EL APLICATION LOAD BALANCER ###
resource "aws_lb" "carlosgb-ALB" {
  name               = "carlosgb-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.carlosgb-SG-HTTP.id,aws_security_group.carlosgb-SG-HTTPS.id]
  subnets            = [aws_subnet.subnet-public-1.id, aws_subnet.subnet-public-2.id]
  tags = {
    Name    = "carlosgb-ALB"
    Project = "laboratorio 4"
    Owner   = "carlosgb"
  }
}

## CREAMOS LOS LISTENER DEL APLICATION LOAD BALANCER ###
resource "aws_lb_listener" "carlosgb-ALB-listener-HTTP" {
  load_balancer_arn = aws_lb.carlosgb-ALB.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.carlosgb-TG.arn
  }
}

resource "aws_lb_listener" "carlosgb-ALB-listener-HTTPS" {
  load_balancer_arn = aws_lb.carlosgb-ALB.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.carlosgb-ssl.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.carlosgb-TG.arn
  }
}

## CREAMOS EL AUTO SCALING GROUP ###
resource "aws_autoscaling_group" "carlosgb-ASG" {
  min_size         = 2
  max_size         = 3
  desired_capacity = 2
  launch_template {
    id      = aws_launch_template.carlosgb-LT.id
    version = "$Latest"
  }
  vpc_zone_identifier = [aws_subnet.subnet-private-11.id, aws_subnet.subnet-private-22.id]
  target_group_arns   = [aws_lb_target_group.carlosgb-TG.arn]
}

resource "aws_elasticache_subnet_group" "example" {
  name       = "my-cache-subnet"
  subnet_ids = [aws_subnet.subnet-private-11.id, aws_subnet.subnet-private-22.id]
}


### CREAMOS UNA INSTANCIA DE ELASTICCHACHE REDIS  ###
resource "aws_elasticache_cluster" "redis_cluster" {
  cluster_id           = "my-redis-cluster"
  engine               = "redis"
  node_type            = "cache.t2.micro" 
  engine_version       = "6.x"          
  num_cache_nodes      = 1                
  parameter_group_name = "default.redis6.x" 
  port                 = 6379

  subnet_group_name  = aws_elasticache_subnet_group.example.name
  security_group_ids = [aws_security_group.carlosgb-SG-REDIS.id]

  tags = {
    Name    = "carlosgb-REDIS"
    Project = "laboratorio 4"
    Owner   = "carlosgb"
  }
}

### REGISTRO CNAME PARA LA CACHE REDIS  ###
resource "aws_route53_record" "redis_record" {
  zone_id = aws_route53_zone.carlosgb-private-host.zone_id
  name    = "carlosgb-redis-interno"
  type    = "CNAME"
  ttl     = 300
  records = [aws_elasticache_cluster.redis_cluster.cache_nodes[0].address]
}

### CREAMOS EL EFS  ###
resource "aws_efs_file_system" "example" {
  creation_token   = "example-efs"
  performance_mode = "generalPurpose"
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
  tags = {
    Name    = "carlosgb-EFS"
    Project = "laboratorio 4"
    Owner   = "carlosgb"
  }
}

resource "aws_efs_mount_target" "uno" {
  file_system_id = aws_efs_file_system.example.id
  subnet_id      = aws_subnet.subnet-private-11.id
}

resource "aws_efs_mount_target" "dos" {
  file_system_id = aws_efs_file_system.example.id
  subnet_id      = aws_subnet.subnet-private-22.id
}


### CREAMOS EL BUCKET DE S3 ###
resource "aws_s3_bucket" "almacencarlos" {
  bucket = "agrjus12547"

  tags = {
    Name = "carlos-Bucket"
    Project = "laboratorio 4"
    Owner   = "carlosgb"
  }
}

### CREAMOS LAS POLITICAS DE ACCESO  ###
resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket                  = aws_s3_bucket.almacencarlos.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}


### IDENTIDAD DE ACCESO DE ORIGEN PARA CLOUDFRONT ###
resource "aws_cloudfront_origin_access_identity" "carlosgb-OAI" {
  comment = "Acceso al s3 desde CloudFront"
}

### CREAMOS LA POLICY DEL BUCKET DE S3 ###
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.almacencarlos.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { AWS = aws_cloudfront_origin_access_identity.carlosgb-OAI.iam_arn },
        Action    = "s3:GetObject",
        Resource = ["${aws_s3_bucket.almacencarlos.arn}",
                    "${aws_s3_bucket.almacencarlos.arn}/*"] ##acceso a objetos dentro del bucket
      }
    ]
  })
}

### CREAMOS LA DISTRIBUCION DE CLOUDFRONT ###
resource "aws_cloudfront_distribution" "carlosgb-cloudfront" {
  origin {
    domain_name = aws_s3_bucket.almacencarlos.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.almacencarlos.id
  }
  enabled             = true
  default_root_object = "*"

  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.almacencarlos.id
    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist" 
      locations        = ["ES", "CA", "GB", "DE"] # solo las ubicaciones especificadas tendrán acceso al recurso
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

}

### CREAMOS LA MEMCACHE ###
resource "aws_elasticache_cluster" "memcache_cluster" {
  cluster_id           = "my-memcache-cluster"
  engine               = "memcached"
  node_type            = "cache.t3.micro" 
  num_cache_nodes      = 1               
  port                 = 11211
  parameter_group_name = "default.memcached1.6"
  security_group_ids   = [aws_security_group.carlosgb-SG-MEMCACHE.id]
  subnet_group_name    = aws_elasticache_subnet_group.example.name
  tags = {
    Name = "carlos-MEMCACHE"
    Project = "laboratorio 4"
    Owner   = "carlosgb"
  }
}

