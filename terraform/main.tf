provider "aws" {
  region = "us-west-2"
  profile = "personal"
}

module "vpc" {
  source = "./modules/vpc"
}
module "etcd_cluster" {
  source = "./modules/etcd_cluster"
  cluster_name = var.cluster_name
  vpc_id = module.vpc.vpc_id
  etcd_ami_version = var.universal_image_version
  use_subnets = [module.vpc.us-west-2a-private-subnet_id, module.vpc.us-west-2b-private-subnet_id, module.vpc.us-west-2c-private-subnet_id]

}

module "k8s_masters" {
  source = "./modules/k8s_masters/"
  cluster_name = var.cluster_name
  vpc_id = module.vpc.vpc_id
  use_subnets = [module.vpc.us-west-2a-private-subnet_id, module.vpc.us-west-2b-private-subnet_id, module.vpc.us-west-2c-private-subnet_id]
  master_ami_version = var.universal_image_version
}
module "platform_services" {
  source = "./modules/platform_services"
  cluster_name = var.cluster_name
}
module "k8s_workers" {
  source = "./modules/k8s_workers/"
  cluster_name = var.cluster_name
  vpc_id = module.vpc.vpc_id
  use_subnets = [module.vpc.us-west-2a-private-subnet_id, module.vpc.us-west-2b-private-subnet_id, module.vpc.us-west-2c-private-subnet_id]
  worker_ami_version = var.universal_image_version
}

