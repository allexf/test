output "instance_id" {
  value = aws_instance.this.id
}

output "alb_dns_name" {
  value = aws_lb.this.dns_name
}

output "target_group_arn" {
  value = aws_lb_target_group.this.arn
}

output "ec2_security_group_id" {
  value = aws_security_group.ec2.id
}

output "alb_security_group_id" {
  value = aws_security_group.alb.id
}
