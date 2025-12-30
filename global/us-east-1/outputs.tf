# Global us-east-1: 출력값

output "certificate_arn" {
  description = "CloudFront용 ACM 인증서 ARN"
  value       = aws_acm_certificate.cloudfront.arn
}

output "certificate_domain_name" {
  description = "인증서 도메인 이름"
  value       = aws_acm_certificate.cloudfront.domain_name
}

output "certificate_status" {
  description = "인증서 상태"
  value       = aws_acm_certificate.cloudfront.status
}
