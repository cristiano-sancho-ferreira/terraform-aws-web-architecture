################@
# Principal
#################

resource "aws_s3_bucket" "app_s3" {
  bucket = "${var.subdomain_name}.${var.domain_name}"

  tags = merge(
    var.common_tags,
    {
      Name = "${var.application_name}-${var.environment}-${var.region}"
    }
  )
}

resource "aws_s3_object" "app_s3_index" {
  bucket       = aws_s3_bucket.app_s3.id
  key          = "index.html"
  source       = "${path.module}/files/index_hiperlink.html"
  etag         = md5("${path.module}/files/index_hiperlink.html")
  content_type = "text/html"
}

resource "aws_s3_object" "app_image" {
  bucket       = aws_s3_bucket.app_s3.id
  key          = "sonic.gif"
  source       = "${path.module}/files/sonic.gif"
  etag         = filemd5("${path.module}/files/sonic.gif")
  content_type = "image/gif"
}

resource "aws_s3_bucket_policy" "app_s3" {
  bucket = aws_s3_bucket.app_s3.id
  policy = data.aws_iam_policy_document.s3_bucket_policy.json
}

data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    sid    = "PublicReadGetObject"
    effect = "Allow"
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "${aws_s3_bucket.app_s3.arn}/*" # Permite acesso a todos os objetos no bucket
    ]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.app_s3.arn]
    }
  }
}

resource "aws_cloudfront_origin_access_control" "app_s3" {
  name                              = "${var.application_name}-${var.environment}-${var.region}"
  description                       = "${var.application_name}-${var.environment}-${var.region}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "app_s3" {
  origin {
    domain_name              = aws_s3_bucket.app_s3.bucket_regional_domain_name
    origin_id                = "S3Origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.app_s3.id
  }

  # Habilitar o WAF
  web_acl_id = aws_wafv2_web_acl.this.arn

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3Origin"

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
    acm_certificate_arn = aws_acm_certificate.this.arn # Substitua pelo ARN do certificado personalizado do ACM
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
    name                   = aws_cloudfront_distribution.app_s3.domain_name
    zone_id                = aws_cloudfront_distribution.app_s3.hosted_zone_id
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



