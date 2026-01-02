# Bootstrap: AWS Provider 설정
# sol-kyeol-bootstrap

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "kyeol"
      Environment = "bootstrap"
      ManagedBy   = "terraform"
      Owner       = "sol"
    }
  }
}
