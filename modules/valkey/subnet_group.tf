# Valkey (ElastiCache) Module: Subnet Group

resource "aws_elasticache_subnet_group" "main" {
  name        = "${var.name_prefix}-cache-subnet-group"
  description = "ElastiCache subnet group for ${var.name_prefix}"
  subnet_ids  = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-cache-subnet-group"
  })
}
