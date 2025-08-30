# ACM Certificate for CloudMart Production
resource "aws_acm_certificate" "cloudmart_cert" {
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "CloudMart Production Certificate"
    Environment = "production"
    Project     = "CloudMart"
    ManagedBy   = "Terraform"
  }
}

# Route53 validation records (only if zone_id is provided)
resource "aws_route53_record" "cert_validation" {
  for_each = var.route53_zone_id != "" ? {
    for dvo in aws_acm_certificate.cloudmart_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.route53_zone_id
}

# Certificate validation (only if Route53 records exist)
resource "aws_acm_certificate_validation" "cloudmart_cert" {
  count = var.route53_zone_id != "" ? 1 : 0
  
  certificate_arn         = aws_acm_certificate.cloudmart_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]

  timeouts {
    create = "5m"
  }
}
