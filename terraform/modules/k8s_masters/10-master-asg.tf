resource "aws_placement_group" "master_placement" {
  name = "master_placement_group"
  strategy = "spread"
}
 
resource "aws_autoscaling_group" "master_cluster" {
  name = "cluster0-k8s"
  min_size = 3
  max_size = 3
  health_check_grace_period = 300
  health_check_type = "EC2"
  placement_group = aws_placement_group.master_placement.id
  launch_configuration = aws_launch_configuration.master_launch_config.name
  vpc_zone_identifier = var.use_subnets
  load_balancers = [aws_elb.k8s_vip.name]
  tag {
    key = "KubernetesCluster" 
    value = var.cluster_name
    propagate_at_launch = true
  }
  tag {
    key = "randomuser.org/usage" 
    value = "control-plane-master"
    propagate_at_launch = true
  }
}
