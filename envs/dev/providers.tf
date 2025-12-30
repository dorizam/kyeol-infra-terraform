# DEV Environment: AWS Provider 설정

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "kyeol"
      Environment = "dev"
      ManagedBy   = "terraform"
      Owner       = "min"
    }
  }
}
