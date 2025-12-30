# Valkey (ElastiCache) Module: 출력값

output "cache_cluster_id" {
  description = "ElastiCache 클러스터 ID"
  value       = aws_elasticache_cluster.main.id
}

output "cache_cluster_arn" {
  description = "ElastiCache 클러스터 ARN"
  value       = aws_elasticache_cluster.main.arn
}

output "cache_nodes" {
  description = "캐시 노드 목록"
  value       = aws_elasticache_cluster.main.cache_nodes
}

output "cache_endpoint" {
  description = "캐시 엔드포인트 (첫 번째 노드)"
  value       = length(aws_elasticache_cluster.main.cache_nodes) > 0 ? aws_elasticache_cluster.main.cache_nodes[0].address : null
}

output "cache_port" {
  description = "캐시 포트"
  value       = var.port
}

output "subnet_group_name" {
  description = "서브넷 그룹 이름"
  value       = aws_elasticache_subnet_group.main.name
}
