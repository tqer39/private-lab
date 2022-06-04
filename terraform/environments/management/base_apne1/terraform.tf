terraform {
  required_version = "=1.2.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "=4.17.1"
    }
  }

  backend "s3" {
    bucket  = "terraform-tfstate-tqer39-577523824419-ap-northeast-1"
    encrypt = true
    key     = "private-lab/terraform/environments/management/management-base_apne1.tfstate"
    region  = "ap-northeast-1"
  }
}
