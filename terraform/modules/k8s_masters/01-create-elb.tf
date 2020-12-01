resource "aws_elb" "k8s_vip" {
  name = "cluster0-k8s"
  security_groups = [aws_security_group.master_sg.id]
  internal = true
  subnets = var.use_subnets
  connection_draining = true
  cross_zone_load_balancing = false
  listener {
    instance_port = 6443
    lb_port = 6443
    lb_protocol = "tcp"
    instance_protocol = "tcp"
  }
}
