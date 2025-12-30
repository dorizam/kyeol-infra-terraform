# Bootstrap: AWS Provider 설정
# min-kyeol-bootstrap

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "kyeol"
      Environment = "bootstrap"
      ManagedBy   = "terraform"
      Owner       = "min"
    }
  }
}
