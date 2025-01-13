# backend.tf - terraform remote state storage in S3

terraform {
  backend "s3" {
    bucket  = "app-terraform-state-bucket"
    key     = "app/dev/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
    acl     = "private"
    dynamodb_table = "app-terraform-state-lock"
  }
}