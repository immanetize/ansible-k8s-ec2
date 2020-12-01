variable "vpc_id" {
  type = string
}
variable "subnet_id" {
  type = string
}


resource "aws_security_group" "bastion" {
  name = "bastion"
  description = "general purpose"
  vpc_id = var.vpc_id
  ingress {
    description = "allow ssh"
    from_port = 0
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }
  tags = {
    Name = "General purpose SG"
  }
}

resource "aws_instance" "bastion-host" {
  ami = "ami-019baded0719b656e"
  instance_type = "t3.small"
  key_name = "aws_id_rsa"
  vpc_security_group_ids = [aws_security_group.bastion.id]
  subnet_id = var.subnet_id
  tags = {
    "Name": "bastion-host"
    "randomuser.org/usage": "testing"
  }
}
  
