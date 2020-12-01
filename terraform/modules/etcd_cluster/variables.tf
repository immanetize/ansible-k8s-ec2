variable "cluster_name" {
  type = string
}

variable "vpc_id" {
  type = string
}
variable "use_subnets" {
  type = list(string)
}
variable "etcd_ami_version" {
  type = string
}
variable "etcd_instance_type" {
  type = string
  default = "t3.small"
}
variable "etcd_ssh_key" {
  type = string
  default = "aws_id_rsa"
}
