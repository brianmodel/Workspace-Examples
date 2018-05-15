terraform {
  backend "s3" {
    bucket  = "sgooch-terreform-test"
    key     = "workspace/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = "true"
    profile = "sandbox"
  }
}
