output "bucket_name" {
  value = aws_s3_bucket.this.bucket
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.this.domain_name
}

output "cloudfront_arn" {
  value = aws_cloudfront_distribution.this.arn
}

variable "web_acl_id" {
  type    = string
  default = null
}