# ECR Module: 출력값

output "repository_arns" {
  description = "ECR 리포지토리 ARN 맵"
  value       = { for k, v in aws_ecr_repository.main : k => v.arn }
}

output "repository_urls" {
  description = "ECR 리포지토리 URL 맵"
  value       = { for k, v in aws_ecr_repository.main : k => v.repository_url }
}

output "repository_names" {
  description = "ECR 리포지토리 이름 맵"
  value       = { for k, v in aws_ecr_repository.main : k => v.name }
}
