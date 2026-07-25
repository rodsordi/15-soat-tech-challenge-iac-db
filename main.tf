module "rds" {
  source         = "./modules/rds"
  db_name        = var.db_name
  db_username    = var.db_username
  instance_class = var.instance_class
  vpc_cidr       = var.vpc_cidr
}

module "observability" {
  source         = "./modules/observability"
  namespace_name = var.namespace_name
}
