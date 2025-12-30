# Global us-east-1: Provider 설정
# CloudFront 인증서는 반드시 us-east-1에서 생성해야 합니다.

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project   = "kyeol"
      ManagedBy = "terraform"
      Owner     = "min"
      Purpose   = "cloudfront-acm"
    }
  }
}
