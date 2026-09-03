data "aws_vpc" "eks_vpc" {
  id = data.aws_eks_cluster.cluster.vpc_config[0].vpc_id
}


data "aws_subnets" "private_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.eks_vpc.id]
  }

  filter {
    name   = "tag:kubernetes.io/role/internal-elb"
    values = ["1"]
  }
}

module "rds" {
  source         = "./modules/rds"
  db_name        = var.db_name
  db_username    = var.db_username
  instance_class = var.instance_class
  vpc_cidr       = var.vpc_cidr
  vpc_id         = data.aws_vpc.eks_vpc.id
  subnet_ids     = data.aws_subnets.private_subnets.ids
}

module "observability" {
  source         = "./modules/observability"
  namespace_name = var.namespace_name
}

