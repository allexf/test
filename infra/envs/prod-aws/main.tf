#################################
# ec2_with_alb
#################################


module "ec2_with_alb" {
  source = "../../modules/ec2_with_alb"

  name               = "${var.project}-${var.environment}"
  alb_name           = "${var.project}-${var.environment}"
  vpc_id             = var.vpc_id
  subnet_id          = var.ec2_subnet_id
  alb_subnet_ids     = var.subnet_ids
  ami_id             = var.ami_id
  ssh_key_name       = var.ssh_key_name
  instance_type      = var.instance_type
  ecr_repository_arn = module.ecr.repository_arn

  tags = local.common_tags
}


#################################
# ECR
#################################

module "ecr" {
  source = "../../modules/ecr"

  name = "${var.project}"

  tags = local.common_tags
}

#################################
# IAM OIDC GitHub
#################################

module "github_oidc" {
  source = "../../modules/iam_oidc_github"

  github_org         = var.github_login
  github_repo        = var.github_repo
  aws_region         = var.aws_region
  aws_account_id     = var.aws_account_id
  ecr_repository_arn = module.ecr.repository_arn

  tags = local.common_tags
}

module "rds" {
  source  = "../../modules/rds"
  enabled = var.rds_enabled
  tags    = local.common_tags
}

#################################
# Static site + CloudFront (us-east-1)
#################################

module "static_site" {
  source = "../../modules/static_site"

  providers = {
    aws = aws.us_east_1
  }

  name = var.static_site_bucket_name
  web_acl_id = module.waf.web_acl_arn
  tags = local.common_tags
}

#################################
# WAF for CloudFront (us-east-1)
#################################

module "waf" {
  source = "../../modules/waf"

  providers = {
    aws = aws.us_east_1
  }

  name             = "${var.project}-waf"
  #cloudfront_arn  = module.static_site.cloudfront_arn
  tags             = local.common_tags
}
