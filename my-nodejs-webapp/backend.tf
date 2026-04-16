# Store terraform state in an S3 bucket
terraform {
  backend "s3" {
    bucket = "chuckys-remote-state"
    key    = "my-nodejs-webapp/terraform.tfstate"
    region = "eu-west-2" # London region
  }
}
