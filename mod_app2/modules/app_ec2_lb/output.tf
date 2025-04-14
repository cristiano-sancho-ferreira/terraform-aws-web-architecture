output "site_url" {
  description = "URL do site"
  value       = "${aws_route53_record.this.name}.${data.aws_route53_zone.this.name}"
}