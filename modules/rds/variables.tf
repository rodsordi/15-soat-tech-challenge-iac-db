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

variable "instance_class" {
  type        = string
  description = "RDS instance class"
  default     = "db.t3.micro"
}

variable "vpc_cidr" {
  type        = string
  description = "EKS VPC CIDR for Ingress"
  default     = "10.0.0.0/16"
}
