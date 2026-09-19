variable "aws_region" {
  type        = string
  description = "AWS Region"
  default     = "us-east-1"
}

variable "cidr_block" {
  default = "0.0.0.0/0"
}

variable "aws_instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "ami_id" {
  type        = string
  description = "Ubuntu 24.04 LTS AMI for us-east-1 (x86)"
  default     = "ami-0f8a61b66d1accaee"
}


variable "db_username" {
  type        = string
  description = "Database administrator username"
  default     = "dbadmin"
}

variable "db_password" {
  type        = string
  description = "Database administrator password"
  sensitive   = true
  default     = "TaskApp2026!"
}
