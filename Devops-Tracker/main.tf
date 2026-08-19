resource "aws_key_pair" "tracker_key" {
  key_name   = "devops_tracker"
  public_key = file("~/.ssh/devops_tracker.pub")
}

resource "aws_security_group" "web_server_sg" {
  name        = "devops_tracker_sg"
  description = "Allow SSH access"
  vpc_id      = data.aws_vpc.default.id

  #Inbound Rules
  #SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.cidr_block
  }

  #Application Access
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = var.cidr_block
  }

  #Outbound Rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.cidr_block
  }
}


resource "aws_instance" "devops_tracker" {
  ami           = var.ami_id
  instance_type = var.aws_instance_type

  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.web_server_sg.id]
  associate_public_ip_address = true


  key_name = aws_key_pair.tracker_key.key_name

  tags = {
    Name = "Web server with Docker"
  }

}

output "public_ip" {
  value       = aws_instance.devops_tracker.public_ip
  description = "Public IP address of the web server"
}

