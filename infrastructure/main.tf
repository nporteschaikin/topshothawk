terraform {
  required_version = "0.14.7"

  backend "s3" {
    bucket = "com.nporteschaikin.terraform"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

locals {
  aws_key_pair_name = "topshothawk-${terraform.workspace}"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_ecr_repository" "migrator" {
  name = "topshothawk-${terraform.workspace}/migrator"
}

resource "aws_ecr_repository" "consumer" {
  name = "topshothawk-${terraform.workspace}/consumer"
}

module "vpc" {
  source = "./modules/vpc"

  key_pair_name = local.aws_key_pair_name
}

module "bastion" {
  source = "./modules/bastion"

  vpc_id        = module.vpc.id
  subnet_id     = module.vpc.public_subnets[0]
  key_pair_name = local.aws_key_pair_name
}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = "topshothawk-${terraform.workspace}"
  retention_in_days = 1
}

resource "aws_ecs_cluster" "nexus" {
  name               = "topshothawk-${terraform.workspace}-nexus"
  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 0
    capacity_provider = "FARGATE"
    weight            = 1
  }
}

module "postgres" {
  source = "./modules/postgres"

  name            = "topshothawk-${terraform.workspace}-postgres"
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.id
  security_groups = [module.listener.security_group_id, module.recorder.security_group_id, module.migrator.security_group_id, module.bastion.security_group_id]
}

module "redis" {
  source = "./modules/redis"

  name            = "topshothawk-${terraform.workspace}-redis"
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.id
  security_groups = [module.listener.security_group_id, module.recorder.security_group_id, module.bastion.security_group_id]
}

module "listener" {
  source = "./modules/consumer"

  service_name         = "listener"
  ecs_cluster_id       = aws_ecs_cluster.nexus.id
  ecr_repository_url   = aws_ecr_repository.consumer.repository_url
  vpc_id               = module.vpc.id
  subnets              = module.vpc.private_subnets
  cloudwatch_log_group = aws_cloudwatch_log_group.log_group.name

  database_endpoint = module.postgres.endpoint
  database_username = module.postgres.service_username
  database_password = module.postgres.service_password
  database_name     = module.postgres.database_name
  redis_endpoint    = module.redis.endpoint

  command = ["listen"]
}

module "fetchers" {
  for_each = {
    "moment-purchased" : "Market.MomentPurchased"
    "moment-listed" : "Market.MomentListed"
    "moment-withdrawn" : "Market.MomentWithdrawn"
    "moment-price-changed" : "Market.MomentPriceChanged"
  }

  source = "./modules/consumer"

  service_name         = "${each.key}-fetcher"
  ecs_cluster_id       = aws_ecs_cluster.nexus.id
  ecr_repository_url   = aws_ecr_repository.consumer.repository_url
  vpc_id               = module.vpc.id
  subnets              = module.vpc.private_subnets
  cloudwatch_log_group = aws_cloudwatch_log_group.log_group.name

  database_endpoint = module.postgres.endpoint
  database_username = module.postgres.service_username
  database_password = module.postgres.service_password
  database_name     = module.postgres.database_name
  redis_endpoint    = module.redis.endpoint

  command = ["fetch", each.value]
}

module "recorder" {
  source = "./modules/consumer"

  service_name         = "recorder"
  ecs_cluster_id       = aws_ecs_cluster.nexus.id
  ecr_repository_url   = aws_ecr_repository.consumer.repository_url
  vpc_id               = module.vpc.id
  subnets              = module.vpc.private_subnets
  cloudwatch_log_group = aws_cloudwatch_log_group.log_group.name

  database_endpoint = module.postgres.endpoint
  database_username = module.postgres.service_username
  database_password = module.postgres.service_password
  database_name     = module.postgres.database_name
  redis_endpoint    = module.redis.endpoint

  desired_count = 3

  command = ["record"]
}

module "migrator" {
  source = "./modules/migrator"

  service_name         = "migrator"
  ecs_cluster_id       = aws_ecs_cluster.nexus.id
  ecr_repository_url   = aws_ecr_repository.migrator.repository_url
  vpc_id               = module.vpc.id
  subnets              = module.vpc.private_subnets
  cloudwatch_log_group = aws_cloudwatch_log_group.log_group.name

  database_endpoint = module.postgres.endpoint
  database_username = module.postgres.service_username
  database_password = module.postgres.service_password
  database_name     = module.postgres.database_name
}
