data "aws_ami" "master_ami" {
  owners = ["self"]
  filter {
    name = "tag:randomuser.org/version"
    values = [var.master_ami_version]
  }
}

resource "aws_security_group" "master_sg" {
  name = "master_sg"
  description = "master cluster sg"
  vpc_id = var.vpc_id
  ingress {
    description = "k8s api"
    from_port = 6443
    to_port = 6443
    protocol = "tcp"
    cidr_blocks = ["10.27.0.0/16"]
  }
ingress {
    description = "kubelet api"
    from_port = 10250
    to_port = 10250
    protocol = "tcp"
    cidr_blocks = ["10.27.64.0/18"]
  }
ingress {
    description = "hail mary"
    from_port = 0
    to_port = 0
    protocol = "tcp"
    cidr_blocks = ["10.27.0.0/16"]
  }
  ingress {
    description = "management access"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["10.27.0.0/16"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name": "master_sg"
    "randomuser.org/usage": "control-plane"
    "KubernetesCluster": var.cluster_name
  }

}

resource "aws_launch_configuration" "master_launch_config" {
  name_prefix = "master_launch_config-"
  image_id = data.aws_ami.master_ami.id
  instance_type = var.master_instance_type
  iam_instance_profile = "master_node_profile"
  lifecycle {
    create_before_destroy = true
  }
  key_name = var.master_ssh_key
  security_groups = [ aws_security_group.master_sg.id ]
  user_data = var.master_user_data
}


