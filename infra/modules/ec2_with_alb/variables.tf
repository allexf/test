variable "tags" { type = map(string) }

variable "name" {
  description = "Base name for resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for EC2"
  type        = string
}

variable "alb_subnet_ids" {
  description = "Subnets for ALB"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "ami_id" {
  description = "AMI ID (default Amazon Linux 2023 ARM)"
  type        = string
}

variable "ssh_key_name" {
  description = "SSH key name"
  type        = string
}

variable "alb_name" {
  description = "ALB name"
  type        = string
}

variable "ecr_repository_arn" {
  type        = string
}

variable "alb_logs_bucket_name" {
  description = "S3 bucket name for ALB access logs"
  type        = string
  default     = "alb-logs-bucket-exeish3i"
}
