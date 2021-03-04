resource "aws_security_group" "security_group" {
  name   = var.name
  vpc_id = var.vpc_id

  ingress {
    from_port = 6379
    to_port   = 6379
    protocol  = "tcp"

    security_groups = var.security_groups
  }
}

resource "aws_elasticache_subnet_group" "subnet_group" {
  name       = var.name
  subnet_ids = var.subnets
}

resource "aws_elasticache_replication_group" "replication_group" {
  replication_group_id          = var.name
  replication_group_description = var.name
  engine                        = "redis"
  node_type                     = "cache.t2.medium"
  number_cache_clusters         = 1
  parameter_group_name          = "default.redis3.2"
  engine_version                = "3.2.10"
  port                          = 6379
  subnet_group_name             = aws_elasticache_subnet_group.subnet_group.id
  security_group_ids            = [aws_security_group.security_group.id]
}
