resource "aws_placement_group" "worker_placement" {
  name = "worker_placement_group"
  strategy = "spread"
}
 
resource "aws_autoscaling_group" "worker_cluster" {
  name_prefix = "cluster0-k8s-workers--"
  lifecycle {
    create_before_destroy = true
  }
  min_size = 3
  max_size = 12
  health_check_grace_period = 300
  health_check_type = "EC2"
  placement_group = aws_placement_group.worker_placement.id
  launch_configuration = aws_launch_configuration.worker_launch_config.name
  vpc_zone_identifier = var.use_subnets
  tag {
    key = "KubernetesCluster" 
    value = var.cluster_name
    propagate_at_launch = true
  }
  tag {
    key = "randomuser.org/usage" 
    value = "worker"
    propagate_at_launch = true
  }
}
