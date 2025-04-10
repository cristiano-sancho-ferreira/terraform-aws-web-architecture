output "subnet_lambda_ids" {
  value = [
    aws_subnet.subnet-lambda-a.id,
    aws_subnet.subnet-lambda-b.id
  ]
  description = "IDs das subnets privadas usadas pelo Lambda"
}

output "lambda_security_group_id" {
  value = aws_security_group.lambda_security_group.id
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}