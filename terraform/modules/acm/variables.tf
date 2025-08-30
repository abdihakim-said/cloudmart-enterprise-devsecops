variable "domain_name" {
  description = "Primary domain name for the certificate"
  type        = string
  default     = "cloudmart.example.com"
}

variable "subject_alternative_names" {
  description = "Additional domain names for the certificate"
  type        = list(string)
  default     = ["*.cloudmart.example.com", "api.cloudmart.example.com"]
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID for DNS validation"
  type        = string
}
