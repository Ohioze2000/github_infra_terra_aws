# Create Hosted Zone
resource "aws_route53_zone" "primary" {
  name = var.domain_name
}

# Route 53 Hosted Zone
resource "aws_route53_record" "root" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.alb_id.dns_name        # or aws_instance.web.public_dns
    zone_id                = var.alb_id.zone_id        # ALB zone ID
    evaluate_target_health = true
  }
}

# Alias record for the www subdomain
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "www.${var.domain_name}" # The www subdomain
  type    = "A"
  alias {
    name                   = var.alb_id.dns_name
    zone_id                = var.alb_id.dns_name
    evaluate_target_health = true
  }
  
}

# Add DNS Validation Record
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in vair.cert_id.domain_validation_options : dvo.domain_name => {
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