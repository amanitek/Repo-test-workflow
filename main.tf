terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "aws_region" {
  type = string
}

provider "aws" {
  region = var.aws_region
}

# If answers[6] === "yes"
resource "aws_security_group" "lb_sg" {
  name        = "lb-sg"
  description = "Allow HTTP"
  
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
}

# If answers[2] === "yes"
resource "aws_s3_bucket" "frontend" {
  bucket = "my-frontend-bucket-${var.aws_region}"
}

# If answers[3] === "yes"
resource "aws_cloudfront_distribution" "cdn" {
  enabled = true
  origin {
    domain_name = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_id   = "S3Origin"
  }
}

# If answers[4] === "yes"
resource "aws_api_gateway_rest_api" "api" {
  name        = "my-api"
  description = "My test API"
}

# If answers[5] === "yes"
resource "aws_lb" "my_lb" {
  name               = "my-load-balancer"
  internal           = false
  load_balancer_type = "application"
  subnets            = ["subnet-12345678", "subnet-87654321"]
  
  # If answers[6] === "yes"
  security_groups    = [aws_security_group.lb_sg.id]
}

# If answers[7] === "yes"
resource "aws_ecs_cluster" "main" {
  name = "my-ecs-cluster"
}
