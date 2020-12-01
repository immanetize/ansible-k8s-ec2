variable "use_subnets" {
  type = list(string)
}

variable "master_ssh_key" {
  type = string
  default = "aws_id_rsa"
}
variable "vpc_id" {
  type = string 
}
variable "cluster_name" {
  type = string 
}
variable "master_ami_version" {
  type = string
}

variable "master_instance_type" {
  type = string
  default = "t3.small"
}
