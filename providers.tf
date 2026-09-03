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
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
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

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}
