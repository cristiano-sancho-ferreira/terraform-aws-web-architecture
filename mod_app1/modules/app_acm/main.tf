########################################################################
# Criação de um certificado SSL
########################################################################
resource "aws_acm_certificate" "this" {
  domain_name       = "${var.subdomain_name}.${var.domain_name}"
  validation_method = "DNS"
  tags = merge(
    var.common_tags,
    {
      Name = "${var.application_name}-${var.environment}-acm-certificate"
    },
  )
}

# Solicitar a validação do certificado SSL.
resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [aws_route53_record.certificate_validation.fqdn]
}

# Validar o certificado SSL usando um registro DNS do Route 53.
resource "aws_route53_record" "certificate_validation" {
  name    = tolist(aws_acm_certificate.this.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.this.domain_validation_options)[0].resource_record_type
  records = [tolist(aws_acm_certificate.this.domain_validation_options)[0].resource_record_value]
  zone_id = data.aws_route53_zone.this.zone_id
  ttl     = 60

  depends_on = [aws_acm_certificate.this]
}

