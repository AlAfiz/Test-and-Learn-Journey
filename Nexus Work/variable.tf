variable "aws_region" {
  description = "AWS region"
  type = string
  default = "us-east-1"
}

variable "cidr_block" {
  default = ["0.0.0.0/0"]
}

variable "instance_type" {
  description = "AWS EC2 Instance type"
  type = string
  default = "m7i-flex.large"
}

variable "ami_id" {
  description = "Ubuntu 24.04 LTS AMI for us-east-1 (x86)"
  type = string
  default = "ami-04b4f1a9cf54c11d0"
}