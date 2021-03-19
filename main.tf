provider "aws" {
  region = "us-west-1"
}

locals {
  kubernetes_version         = "1.19"
  eks_worker_ami_name_filter = "amazon-eks-node-${local.kubernetes_version}"
}

module "vpc" {
  source = "cloudposse/vpc/aws"
  # Cloud Posse recommends pinning every module to a specific version
  # version     = "x.x.x"
  cidr_block = "172.16.0.0/16"
}

module "subnets" {
  source = "cloudposse/dynamic-subnets/aws"
  # Cloud Posse recommends pinning every module to a specific version
  # version     = "x.x.x"
  availability_zones   = ["us-west-1a", "us-west-1c"]
  vpc_id               = module.vpc.vpc_id
  igw_id               = module.vpc.igw_id
  cidr_block           = module.vpc.vpc_cidr_block
  nat_gateway_enabled  = false
  nat_instance_enabled = false
}

module "eks_node_group" {
  source = "cloudposse/eks-node-group/aws"
  # Cloud Posse recommends pinning every module to a specific version
  # version     = "x.x.x"
  subnet_ids                = module.subnets.public_subnet_ids
  instance_types            = ["t3.medium"]
  desired_size              = 2
  min_size                  = 2
  max_size                  = 10
  cluster_name              = module.eks_cluster.eks_cluster_id
  kubernetes_version        = local.kubernetes_version
}

module "eks_cluster" {
  source = "cloudposse/eks-cluster/aws"
  # Cloud Posse recommends pinning every module to a specific version
  # version     = "x.x.x"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.subnets.public_subnet_ids
  region     = "us-west-1"

  kubernetes_version    = local.kubernetes_version
  oidc_provider_enabled = false

  workers_security_group_ids   = []
  workers_role_arns            = [module.eks_node_group.eks_node_group_role_arn]
}
