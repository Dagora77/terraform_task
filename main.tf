provider "aws" {
  region = var.region
}

module "aws_network" {
  source = "./modules/aws_network"
  env    = var.env
}

module "aws_rds" {
  source              = "./modules/aws_rds"
  vpc_id              = module.aws_network.vpc_id
  public_subnet_id_a  = module.aws_network.public_subnet_id_a
  public_subnet_id_b  = module.aws_network.public_subnet_id_b
  private_subnet_id_a = module.aws_network.private_subnet_id_a
  private_subnet_id_b = module.aws_network.private_subnet_id_b
  env_security_group  = module.aws_network.env_security_group
}

module "app" {
  source              = "./modules/app"
  vpc_id              = module.aws_network.vpc_id
  public_subnet_id_a  = module.aws_network.public_subnet_id_a
  public_subnet_id_b  = module.aws_network.public_subnet_id_b
  private_subnet_id_a = module.aws_network.private_subnet_id_a
  private_subnet_id_b = module.aws_network.private_subnet_id_b
  env_security_group  = module.aws_network.env_security_group
  aws_db_php          = module.aws_rds.aws_db_php
  aws_db_php_endpoint = module.aws_rds.aws_db_php_endpoint
}
