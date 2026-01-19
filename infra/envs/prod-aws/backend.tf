terraform {
  backend "s3" {
    bucket         = "terraform-state-2"
    key            = "test-prod/terraform.tfstate"
    region         = "eu-central-1"
    #dynamodb_table = "terraform-locks"
    #encrypt        = true
  }
}

