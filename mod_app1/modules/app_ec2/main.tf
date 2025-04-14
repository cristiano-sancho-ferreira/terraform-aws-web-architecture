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
resource "aws_route53_record" "this" {
  zone_id = data.aws_route53_zone.this.zone_id
  # Substitua pelo seu domínio registrado no Route 53
  name    = var.subdomain_name
  type    = "A"
  records = [aws_instance.this.public_ip]
  ttl     = 300
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




