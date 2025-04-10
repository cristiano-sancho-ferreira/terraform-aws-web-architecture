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

# Criar um registro DNS no Route 53 com o subdomínio "live2" com um alias para a instância EC2.
# resource "aws_route53_record" "this" {
#   zone_id = data.aws_route53_zone.this.zone_id
#   # Substitua pelo seu domínio registrado no Route 53
#   name     = "gabriel"
#   type     = "A"
#   records  = [aws_instance.this.public_ip]
#   ttl      = 300
# }

resource "aws_route53_record" "this" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = var.subdomain_name
  type    = "A"
  alias {
    name                   = aws_lb.this.dns_name
    zone_id                = aws_lb.this.zone_id
    evaluate_target_health = false
  }
}


data "aws_route53_zone" "this" {
  name = var.domain_name
}

# Cria um certificado SSL no AWS ACM para o domínio especificado.
resource "aws_acm_certificate" "this" {
  domain_name       = "${aws_route53_record.this.name}.${data.aws_route53_zone.this.name}"
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


resource "aws_lb_listener" "this_https" {
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
  certificate_arn = aws_acm_certificate_validation.this.certificate_arn

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