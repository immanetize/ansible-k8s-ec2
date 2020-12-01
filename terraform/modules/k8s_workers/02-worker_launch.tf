data "aws_ami" "worker_ami" {
  owners = ["self"]
  filter {
    name = "name"
    values = ["cluster0-universal"]
  }
  filter {
    name = "tag:randomuser.org/hamburger"
    values = ["true"]
  }
  filter {
    name = "tag:randomuser.org/version"
    values = [var.worker_ami_version]
  }
}

resource "aws_security_group" "worker_sg" {
  name = "worker_sg"
  description = "worker cluster sg"
  vpc_id = var.vpc_id
  ingress {
    description = "whatever is private, for now"
    from_port = 0
    to_port = 0
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

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name": "worker_sg"
    "randomuser.org/usage": "worker"
    "KubernetesCluster": var.cluster_name
    "k8s.io/cluster-autoscaler/enabled": "True"
  }

}

resource "aws_launch_configuration" "worker_launch_config" {
  name_prefix = "worker_launch_config-"
  image_id = data.aws_ami.worker_ami.id
  instance_type = var.worker_instance_type
  iam_instance_profile = "worker_node_profile"
  lifecycle {
    create_before_destroy = true
  }
  key_name = var.worker_ssh_key
  security_groups = [ aws_security_group.worker_sg.id ]
  user_data = var.worker_user_data
}


