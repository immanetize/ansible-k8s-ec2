resource "aws_placement_group" "etcd_placement" {
  name = "etcd_placement_group"
  strategy = "spread"
}
 
resource "aws_autoscaling_group" "etcd_cluster" {
  name = "cluster0-etcd"
  min_size = 3
  max_size = 3
  health_check_grace_period = 300
  health_check_type = "EC2"
  placement_group = aws_placement_group.etcd_placement.id
  launch_configuration = aws_launch_configuration.etcd_launch_config.name
  vpc_zone_identifier = var.use_subnets
  tag {
    key = "randomuser.org/cluster" 
    value = var.cluster_name
    propagate_at_launch = true
  }
  tag {
    key = "randomuser.org/usage" 
    value = "control-plane-etcd"
    propagate_at_launch = true
  }
}
