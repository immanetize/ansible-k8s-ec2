variable "use_subnets" {
  type = list(string)
}

variable "worker_ssh_key" {
  type = string
  default = "aws_id_rsa"
}
variable "vpc_id" {
  type = string 
}
variable "cluster_name" {
  type = string 
}
variable "worker_ami_version" {
  type = string
}

variable "worker_instance_type" {
  type = string
  default = "t3.medium"
}
