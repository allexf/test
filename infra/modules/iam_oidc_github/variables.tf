variable "github_org" {
  type        = string
}

variable "github_repo" {
  type        = string
}

variable "aws_region" {
  type        = string
}

variable "aws_account_id" {
  type        = string
}

variable "ecr_repository_arn" {
  type        = string
}

variable "role_name" {
  type    = string
  default = "github-oidc-ecr-push"
}

variable "tags" {
  type    = map(string)
}

