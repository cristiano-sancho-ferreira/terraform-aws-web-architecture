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
  subnet_id             = data.aws_subnets.default.ids[0] # Substitua pelo seu ID de sub-rede
  associate_public_ip_address = true # Atribuir um IP público à instância EC2

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
  vpc_id = data.aws_vpc.default.id

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
}


resource "aws_cloudfront_distribution" "app_lb" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  web_acl_id         = aws_wafv2_web_acl.this.arn
  aliases            = ["${var.subdomain_name}.${var.domain_name}"]

  origin {
    domain_name = aws_lb.this.dns_name
    origin_id   = local.origin_id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.origin_id
    viewer_protocol_policy = "redirect-to-https"
    compress              = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.this.arn
    ssl_support_method  = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.application_name}-${var.environment}-${var.region}"
    }
  )
}

locals {
  origin_id = "ALBOrigin"
}


# Criar um registro DNS no Route 53 com o subdomínio "live2" com um alias para a instância EC2.
resource "aws_route53_record" "this" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = var.subdomain_name
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.app_lb.domain_name
    zone_id                = aws_cloudfront_distribution.app_lb.hosted_zone_id
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



# Criar um Load Balancer do tipo Application Load Balancer (ALB) na VPC default e associar acm-certificate.
# O Load Balancer será acessível publicamente e terá um listener na porta 443 (HTTPS).  
# O listener HTTP será redirecionado para o listener HTTPS
resource "aws_lb" "this" {
  name               = "${var.application_name}-${var.environment}-alb"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  tags = merge(
    var.common_tags,
    {
      Name = "${var.application_name}-${var.environment}-alb"
    },
  )
}

resource "aws_lb_listener" "this_http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.application_name}-${var.environment}-alb-listener-http"
    },
  )
}

# Criar um target group para a instância EC2.
resource "aws_lb_target_group" "this" {
  name     = "${var.application_name}-${var.environment}-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-299"
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.application_name}-${var.environment}-target-group"
    },
  )
}

# Attach the EC2 instance to the target group
resource "aws_lb_target_group_attachment" "this" {
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = aws_instance.this.id
  port             = 80
}






