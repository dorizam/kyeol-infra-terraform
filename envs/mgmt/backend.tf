# MGMT Environment: S3 원격 백엔드

terraform {
  backend "s3" {
    bucket         = "sol-kyeol-tfstate-827913617839-ap-northeast-3"
    key            = "mgmt/terraform.tfstate"
    region         = "ap-northeast-3"
    dynamodb_table = "sol-kyeol-tfstate-lock"
    encrypt        = true
  }
}
