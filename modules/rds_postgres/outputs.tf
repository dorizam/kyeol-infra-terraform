# RDS PostgreSQL Module: 출력값

output "db_instance_id" {
  description = "RDS 인스턴스 ID"
  value       = aws_db_instance.main.id
}

output "db_instance_arn" {
  description = "RDS 인스턴스 ARN"
  value       = aws_db_instance.main.arn
}

output "db_instance_endpoint" {
  description = "RDS 엔드포인트"
  value       = aws_db_instance.main.endpoint
}

output "db_instance_address" {
  description = "RDS 호스트 주소"
  value       = aws_db_instance.main.address
}

output "db_instance_port" {
  description = "RDS 포트"
  value       = aws_db_instance.main.port
}

output "db_name" {
  description = "데이터베이스 이름"
  value       = aws_db_instance.main.db_name
}

output "db_username" {
  description = "마스터 사용자 이름"
  value       = aws_db_instance.main.username
  sensitive   = true
}

output "db_secret_arn" {
  description = "Secrets Manager 시크릿 ARN"
  value       = aws_secretsmanager_secret.rds.arn
}

output "db_subnet_group_name" {
  description = "DB 서브넷 그룹 이름"
  value       = aws_db_subnet_group.main.name
}

output "db_parameter_group_name" {
  description = "DB 파라미터 그룹 이름"
  value       = aws_db_parameter_group.main.name
}
