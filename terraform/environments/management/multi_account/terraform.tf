terraform {
  required_version = "=1.2.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "=4.22.0"
    }
  }

  backend "s3" {
    bucket  = "terraform-tfstate-tqer39-577523824419-ap-northeast-1"
    encrypt = true
    key     = "private-lab/terraform/environments/management/management-multi_account.tfstate"
    region  = "ap-northeast-1"
  }
}
