module "s3-bucket" {
  source = "../../../modules/s3/bucket"

  aws_s3_bucket = {
    bucket = var.bucket_name
  }
  aws_s3_bucket_versioning = {
    versioning_configuration = [
      {
        status = "Enabled"
      }
    ]
  }
}
