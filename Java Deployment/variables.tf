variable "aws_region" {
  description = "AWS Region"
  type = string
  default = "us-east-1"
}

variable "instance_type" {
  description = "Instance Type"
  type = string
  default = "t3.micro"
}

variable "ami_id" {
  description = "Ubuntu 24.04 LTS AMI for us-east-1 (x86)"
  type = string
  default = "ami-04b4f1a9cf54c11d0"
}

variable "cidr_blocks" {
  description = "CIDR BLOCKS"
  default = ["0.0.0.0/0"]
}

variable "my_public_ip_address" {
  description = "My computer's IP Address"
  default = ["98.97.77.240/32"]
}