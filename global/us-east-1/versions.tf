# Global us-east-1: CloudFront ACM 인증서
# Phase-1 미적용 (계획만), Phase-2에서 활성화

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}
