terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }

  # Uncomment and configure this block if you want to use remote state
  # backend "s3" {
  #   bucket         = "XXXXXXXXXXXXXXXXXXXXXX"
  #   key            = "datalake/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-state-lock"
  #   encrypt        = true
  # }
}
