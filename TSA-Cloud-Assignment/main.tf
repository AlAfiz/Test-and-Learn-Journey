resource "aws_key_pair" "tsa_cloud_tasks" {
  key_name   = "tsa_cloud"
  public_key = file("~/.ssh/tsa_cloud.pub")
}

#Security group for Backend SG
resource "aws_security_group" "Backend_SG" {
  name        = "tsa_cloud_sg"
  description = "Allow SSH Access"
  vpc_id      = data.aws_vpc.default.id


  #Inbound rules
  #SSH Access 
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block]
  }

  #Inbound rules
  #API Access
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block]
  }

  #Outbound rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.cidr_block]
  }
}


#Security group for database

resource "aws_security_group" "Database_SG" {
  name        = "tsa_cloud_db_sg"
  description = "Allow PostgreSQL traffic from Backend only"
  vpc_id      = data.aws_vpc.default.id


  #Inbound rules
  # PostgreSQL Access strictly from Backend SG
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.Backend_SG.id]
  }


  #Outbound Rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.cidr_block]
  }

}


#EC2 Server for the Backend
resource "aws_instance" "backend_server" {
  ami           = var.ami_id
  instance_type = var.aws_instance_type
  key_name      = aws_key_pair.tsa_cloud_tasks.key_name

  #Attaching backend security group
  vpc_security_group_ids = [aws_security_group.Backend_SG.id]

  tags = {
    Name = "TaskApp Backend"
  }
}


#Resource for RDS Database 
resource "aws_db_instance" "taskapp_db" {
  allocated_storage   = 20
  engine              = "postgres"
  engine_version      = "16.3"
  instance_class      = "db.t3.micro"
  identifier          = "taskapp-db"
  username            = var.db_username
  password            = var.db_password
  skip_final_snapshot = true
  publicly_accessible = false

  vpc_security_group_ids = [aws_security_group.Database_SG.id]
}


# S3 Bucket for Frontend
resource "aws_s3_bucket" "frontend_bucket" {
  # S3 bucket names must be globally unique. Change this to something unique!
  bucket = "taskapp-frontend-unique-id-2026"

  force_destroy = true
}

# Enable Static Website Hosting
resource "aws_s3_bucket_website_configuration" "frontend_website" {
  bucket = aws_s3_bucket.frontend_bucket.id

  index_document {
    suffix = "index.html"
  }
}

# Disable Block Public Access to allow the bucket to be public
resource "aws_s3_bucket_public_access_block" "frontend_public_access" {
  bucket = aws_s3_bucket.frontend_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# S3 Bucket Policy to make the bucket public
resource "aws_s3_bucket_policy" "frontend_public_policy" {
  bucket = aws_s3_bucket.frontend_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.frontend_bucket.arn}/*"
      },
    ]
  })

  # Ensure the public access block is removed before applying this policy
  depends_on = [aws_s3_bucket_public_access_block.frontend_public_access]
}

# CloudFront Distribution for the Frontend
resource "aws_cloudfront_distribution" "frontend_cdn" {
  enabled             = true
  default_root_object = "index.html"

  origin {
    domain_name = aws_s3_bucket_website_configuration.frontend_website.website_endpoint
    origin_id   = "S3-taskapp-frontend"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-taskapp-frontend"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}
