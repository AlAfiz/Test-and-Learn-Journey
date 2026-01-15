#SSH key
resource "aws_key_pair" "my_ssh_key" {
  key_name = "zacks-clean-key-working"
  public_key = file("C:/Users/Public/id_aws.pub")
}
#firewalls

#allow ssh authentication
resource "aws_security_group" "allow_ssh" {
  name = "allow_ssh_traffic"
  description = "Allow SSH Inbound traffic"

  #INBOUND for  SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.cidr_blocks
  }

  #INBOUND for Application Access
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = var.cidr_blocks
  }

  #OUTBOUND
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = var.cidr_blocks
  }
}

#Instance
resource "aws_instance" "my_server_with_tech_with_nana" {
  ami = var.ami_id
  instance_type = var.instance_type
  key_name = aws_key_pair.my_ssh_key.key_name

  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    Name = "My-final-ubuntu-server-Ready-to-Connect"
  }
}
output "server_ip" {
  value = aws_instance.my_server_with_tech_with_nana.public_ip
}