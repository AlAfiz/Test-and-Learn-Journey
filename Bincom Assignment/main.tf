#SSH Key
resource "aws_key_pair" "Bincom_test_key" {
  key_name   = "Zacks_key_bincom"
  public_key = file("C:/Users/Zacks/.ssh/id_rsa.pub")
  
}

#Firewalls
#Allow ssh
resource "aws_security_group" "allow_ssh" {
  name = "allow_ssh_traffic"
  description = "Allow ssh Connections"

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
    from_port = 80
    to_port = 80
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

#EC2 Instance
resource "aws_instance" "Bincom_test" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name = aws_key_pair.Bincom_test_key.key_name

  vpc_security_group_ids = [aws_security_group.allow_ssh.id]


  tags = {
    Name = "Bincom_test_instance"
  }
}


output "server_ip" {
    value = aws_instance.Bincom_test.public_ip
}
