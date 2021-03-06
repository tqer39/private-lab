terraform {
  required_version = "=1.2.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "=4.22.0"
    }
  }

  backend "s3" {
    bucket  = "terraform-tfstate-tqer39-107662415716-ap-northeast-1"
    encrypt = true
    key     = "private-lab/terraform/environments/sandbox/sandbox-base_apne1.tfstate"
    region  = "ap-northeast-1"
  }
}
