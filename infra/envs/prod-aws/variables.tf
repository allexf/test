variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "rds_enabled" {
  type    = bool
  default = false
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_profile" {
  description = "AWS profile"
  type        = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "ec2_subnet_id" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "ssh_key_name" {
  type = string
}

variable "instance_type" {
  type = string
}


variable "github_repo" {
  type = string
}

variable "github_login" {
  type = string
}

variable "static_site_bucket_name" {
  description = "S3 bucket name for static site"
  type        = string
}

