terraform {
  required_version = ">= 1.10.0" # use_lockfile no backend S3

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
