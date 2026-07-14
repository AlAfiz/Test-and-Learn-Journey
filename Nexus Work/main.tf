#SSH Key
resource "aws_key_pair" "my_ssh_key" {
  key_name = "Zacks-Key-Nexus"
  public_key = file("C:/Users/Public/id_nexus.pub")
}

#Firewalls
#Allow ssh
resource "aws_security_group" "allow_ssh" {
  name = "allow_ssh_traffic"
  description = "Allow SSH Connection"

  #INBOUND RULES
  #SSH
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = var.cidr_block
  }

  #Application Access
  ingress {
    from_port = 8081
    to_port = 8081
    protocol = "tcp"
    cidr_blocks = var.cidr_block
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = var.cidr_block
  }
}

#EC2 instance
resource "aws_instance" "Nexus_Server" {
  ami = var.ami_id
  instance_type = var.instance_type
  key_name = aws_key_pair.my_ssh_key.key_name

  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    Name = "My-Server-For-Nexus"
  }
}

output "server_ip" {
  value = aws_instance.Nexus_Server.public_ip
}