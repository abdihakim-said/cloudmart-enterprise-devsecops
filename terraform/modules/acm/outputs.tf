output "certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = var.route53_zone_id != "" ? aws_acm_certificate_validation.cloudmart_cert[0].certificate_arn : aws_acm_certificate.cloudmart_cert.arn
}

output "certificate_domain_name" {
  description = "Domain name of the certificate"
  value       = aws_acm_certificate.cloudmart_cert.domain_name
}
