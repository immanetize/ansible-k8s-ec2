data "aws_ami" "etcd_ami" {
  owners = ["self"]
  filter {
    name = "tag:randomuser.org/usage"
    values = ["kube_node"]
  }
  filter {
    name = "tag:randomuser.org/version"
    values = [var.etcd_ami_version]
  }
}

resource "aws_security_group" "etcd_sg" {
  name = "etcd_sg"
  description = "etcd cluster sg"
  vpc_id = var.vpc_id
  ingress {
    description = "etcd client"
    from_port = 2379
    to_port = 2379
    protocol = "tcp"
    cidr_blocks = ["10.27.64.0/18"]
  }
  ingress {
    description = "etcd peer"
    from_port = 2380
    to_port = 2380
    protocol = "tcp"
    cidr_blocks = ["10.27.64.0/18"]
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
    "Name": "etcd_sg"
    "randomuser.org/usage": "etcd"
    "KubernetesCluster": var.cluster_name
  }

}

resource "aws_launch_configuration" "etcd_launch_config" {
  name_prefix = "etcd_launch_config-"
  image_id = data.aws_ami.etcd_ami.id
  instance_type = var.etcd_instance_type
  iam_instance_profile = "etcd_node_profile"
  lifecycle {
    create_before_destroy = true
  }
  key_name = var.etcd_ssh_key
  security_groups = [ aws_security_group.etcd_sg.id ]
  user_data = var.etcd_user_data
  root_block_device {
    volume_type = "standard"
    volume_size = "40"
    delete_on_termination = "true"
    encrypted = "false"
  }
}


