variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "cidr_block" {
  default = ["0.0.0.0/0"]
}


variable "aws_instance_type" {
  type        = string
  description = "AWS Instance Type"
  default     = "m7i-flex.large"
}

variable "ami_id" {
  type        = string
  description = "Ubuntu 24.04 LTS AMI for us-east-1 (x86)"
  default     = "ami-0f8a61b66d1accaee"
}