terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket         = "zap-tf-states"
    key            = "dependencies/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}
 