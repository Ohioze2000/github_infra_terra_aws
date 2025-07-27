# Create Hosted Zone
resource "aws_route53_zone" "primary" {
  name = var.domain_name

  tags = {
    Name        = "${var.env_prefix}-hosted-zone"
    ManagedBy   = "Terraform"
  }
}

# Route 53 Hosted Zone
resource "aws_route53_record" "root" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.alb_dns_name        # or aws_instance.web.public_dns
    zone_id                = var.alb_zone_id        # ALB zone ID
    evaluate_target_health = true
  }
}

# Alias record for the www subdomain
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "www.${var.domain_name}" # The www subdomain
  type    = "A"
  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
  
}

# Add DNS Validation Record
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in var.acm_domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = aws_route53_zone.primary.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}