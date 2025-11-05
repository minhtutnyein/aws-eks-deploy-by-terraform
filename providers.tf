terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

provider "aws" {
  region  = var.eks_region
  profile = var.eks_profile

  default_tags {
    tags = {
      ManagedBy   = "Terraform"
      Environment = var.eks_environment
      Project     = "Bookinfo"
    }
  }
}
