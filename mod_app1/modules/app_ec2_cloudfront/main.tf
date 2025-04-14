################@
# Principal
#################

# Criar uma instancia EC2 e instalar apache2 nela.
resource "aws_instance" "this" {
  ami           = data.aws_ami.latest.id
  instance_type = "t3.micro"
  key_name      = "app-instance" # Substitua pelo seu par de chaves 

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y apache2
              sudo systemctl start apache2
              sudo systemctl enable apache2
              echo "<html><body><h1>Bem-vindo ao curso do Gabriel Sancho de AWS!</h1></body></html>" > /var/www/html/index.html
              EOF

  vpc_security_group_ids = [aws_security_group.this.id]

  tags = merge(
    var.common_tags,
    {
      Name = "${var.application_name}-ec2-instance"
    },
  )
}

# Criar um grupo de segurança para a instância EC2.
resource "aws_security_group" "this" {
  name = "${var.application_name}-${var.environment}-security-group"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Permitir acesso HTTP de qualquer lugar
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Permitir acesso HTTPS de qualquer lugar
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_cloudfront_distribution" "app_ec2" {
  origin {
    domain_name = aws_instance.this.public_dns
    origin_id   = "EC2Origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # Habilitar o WAF
  web_acl_id = aws_wafv2_web_acl.this.arn

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "EC2Origin"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  aliases = ["${var.subdomain_name}.${var.domain_name}"]

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.this.arn
    ssl_support_method  = "sni-only"
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.application_name}-${var.environment}-${var.region}"
    }
  )
}


# Criar um registro DNS no Route 53 com o subdomínio "live2" com um alias para a instância EC2.
resource "aws_route53_record" "this" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = var.subdomain_name
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.app_ec2.domain_name
    zone_id                = aws_cloudfront_distribution.app_ec2.hosted_zone_id
    evaluate_target_health = false
  }
}


data "aws_route53_zone" "this" {
  name = var.domain_name
}

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

# Validar o certificado SSL usando um registro DNS do Route 53.
resource "aws_route53_record" "certificate_validation" {
  name    = tolist(aws_acm_certificate.this.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.this.domain_validation_options)[0].resource_record_type
  records = [tolist(aws_acm_certificate.this.domain_validation_options)[0].resource_record_value]
  zone_id = data.aws_route53_zone.this.zone_id
  ttl     = 60
}

# Solicitar a validação do certificado SSL.
resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [aws_route53_record.certificate_validation.fqdn]
}


resource "aws_wafv2_web_acl" "this" {
  name        = "${var.application_name}-${var.environment}-${var.region}"
  description = "${var.application_name}-${var.environment}-${var.region}"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name               = "${var.application_name}-${var.environment}-metric"
    sampled_requests_enabled  = true
  }
}






