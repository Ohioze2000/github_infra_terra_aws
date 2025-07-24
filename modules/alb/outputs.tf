#output "alb_dns" {
#  value = aws_lb.app-alb.dns_name
#}

output "alb_dns_name" { # Using a clearer name for the output
  description = "The DNS name of the Application Load Balancer."
  value       = aws_lb.app-alb.dns_name
}

output "alb_hosted_zone_id" {
  description = "The AWS-managed hosted zone ID for the ALB."
  value       = aws_lb.app-alb.zone_id
}