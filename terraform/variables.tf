variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "serverless-support-api"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region for deploying resources"
  type        = string
  default     = "ap-southeast-1"
}

