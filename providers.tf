terraform {
  backend "s3" {
    bucket = "techchallenge-fiap-tfstate-890958457263"
    key    = "db/terraform.tfstate"
    region = "us-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile != "" && var.aws_profile != "default" ? var.aws_profile : null

  default_tags {
    tags = {
      Project     = "SOAT-TechChallenge"
      Environment = "production"
      ManagedBy   = "Terraform"
    }
  }
}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}
