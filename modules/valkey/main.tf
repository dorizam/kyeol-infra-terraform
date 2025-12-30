# Valkey (ElastiCache) Module: 메인 리소스

resource "aws_elasticache_cluster" "main" {
  cluster_id           = "${var.name_prefix}-cache"
  engine               = var.engine
  engine_version       = var.engine_version
  node_type            = var.node_type
  num_cache_nodes      = var.num_cache_nodes
  port                 = var.port
  parameter_group_name = "default.${var.engine}${replace(var.engine_version, ".", "")}"

  subnet_group_name  = aws_elasticache_subnet_group.main.name
  security_group_ids = var.security_group_ids

  maintenance_window       = var.maintenance_window
  snapshot_retention_limit = var.snapshot_retention_limit

  # Transit encryption (recommended for production)
  # transit_encryption_enabled = true

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-cache"
  })
}
