variable "aws_region" {
  type        = string
  description = "AWS Region"
  default     = "us-east-1"
}

variable "aws_profile" {
  type        = string
  description = "AWS CLI profile name"
  default     = "default"
}


variable "db_name" {
  type        = string
  description = "Database name"
  default     = "postgres"
}

variable "db_username" {
  type        = string
  description = "Master username"
  default     = "postgres"
}

variable "cluster_name" {
  type        = string
  description = "EKS Cluster Name"
  default     = "techchallenge-cluster"
}

variable "namespace_name" {
  type        = string
  description = "Kubernetes namespace for observability"
  default     = "garage"
}

variable "instance_class" {
  type        = string
  description = "RDS instance class"
  default     = "db.t3.micro"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block for RDS Security Group ingress restriction"
  default     = "10.0.0.0/16"
}
