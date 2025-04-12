#############################################################################
# Network
#############################################################################

# Create the VPC
resource "aws_vpc" "vpc" {

  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = merge(var.common_tags, {
    Name = "${var.organization_name}-${var.environment}-vpc"
  })
}

##################### Internet Gateway

# Internet Gateway public Subnet
resource "aws_internet_gateway" "igw" {

  vpc_id = aws_vpc.vpc.id

  tags = merge(var.common_tags, {
    Name = "${var.organization_name}-${var.environment}-igw"

  })
}


#################### Subnet DMZ ####################

# Create the public Subnet 
resource "aws_subnet" "subnet-dmz-a" {

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet_1_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = merge(var.common_tags, {
    Name = "${var.organization_name}-${var.environment}-pub-dmz-a"

  })
}

# Create the public Subnet AZ2
resource "aws_subnet" "subnet-dmz-b" {

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet_2_cidr
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = merge(var.common_tags, {
    Name = "${var.organization_name}-${var.environment}-pub-dmz-b"

  })

}

# Define the public route table
resource "aws_route_table" "rt-pub" {

  vpc_id = aws_vpc.vpc.id

  # route to IGW
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(var.common_tags, {
    Name = "${var.organization_name}-${var.environment}-rt-pub-dmz"

  })
}

# Assign the route table to the public Subnet for IGW 
resource "aws_route_table_association" "subnet-rt-association-igw-dmz-a" {

  subnet_id      = aws_subnet.subnet-dmz-a.id
  route_table_id = aws_route_table.rt-pub.id
}

# Assign the public route table to the redshift Subnet az2 for IGW 
resource "aws_route_table_association" "subnet-rt-association-igw-dmz-b" {

  subnet_id      = aws_subnet.subnet-dmz-b.id
  route_table_id = aws_route_table.rt-pub.id
}


# network acl public
resource "aws_network_acl" "acl_pub" {

  vpc_id = aws_vpc.vpc.id

  tags = merge(var.common_tags, {
    Name = "${var.organization_name}-${var.environment}-acl"

  })
}

resource "aws_network_acl_rule" "ingress" {

  network_acl_id = aws_network_acl.acl_pub.id
  rule_number    = 100
  protocol       = -1
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}

resource "aws_network_acl_rule" "egress" {

  network_acl_id = aws_network_acl.acl_pub.id
  rule_number    = 100
  egress         = true
  protocol       = -1
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}

# Associa a ACL de rede à primeira sub-rede
resource "aws_network_acl_association" "association-dmz-a" {

  subnet_id      = aws_subnet.subnet-dmz-a.id
  network_acl_id = aws_network_acl.acl_pub.id
}

# Associa a ACL de rede à segunda sub-rede
resource "aws_network_acl_association" "association-dmz-b" {

  subnet_id      = aws_subnet.subnet-dmz-b.id
  network_acl_id = aws_network_acl.acl_pub.id
}


#################### Subnet APP ####################

# Create the private Subnet
resource "aws_subnet" "subnet-app-a" {

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet_3_cidr
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = merge(var.common_tags, {
    Name = "${var.organization_name}-${var.environment}-priv-app-a"

  })
}

# Create the private Subnet
resource "aws_subnet" "subnet-app-b" {

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet_4_cidr
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = merge(var.common_tags, {
    Name = "${var.organization_name}-${var.environment}-priv-app-b"

  })
}

# Define the private route table 
resource "aws_route_table" "rt-app" {

  vpc_id = aws_vpc.vpc.id

  # route to NATGW
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }

  tags = merge(var.common_tags, {
    Name = "${var.organization_name}-${var.environment}-rt-priv-app"

  })
}

# Assign the route table subnet private 
resource "aws_route_table_association" "subnet-rt-association-app-a" {

  subnet_id      = aws_subnet.subnet-app-a.id
  route_table_id = aws_route_table.rt-app.id
}

# Assign the public route table to the redshift Subnet az2 for IGW 
resource "aws_route_table_association" "subnet-rt-association-app-b" {

  subnet_id      = aws_subnet.subnet-app-b.id
  route_table_id = aws_route_table.rt-app.id
}

#################### Subnet DB ####################

# Create the private Subnet
resource "aws_subnet" "subnet-db-a" {

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet_5_cidr
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = merge(var.common_tags, {
    Name = "${var.organization_name}-${var.environment}-priv-db-a"

  })
}

# Create the private Subnet
resource "aws_subnet" "subnet-db-b" {

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet_6_cidr
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = merge(var.common_tags, {
    Name = "${var.organization_name}-${var.environment}-priv-db-b"
  })
}

# Define the private route table 
resource "aws_route_table" "rt-db" {

  vpc_id = aws_vpc.vpc.id

  # route to NATGW
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }

  tags = merge(var.common_tags, {
    Name = "${var.organization_name}-${var.environment}-rt-priv-db"
  })
}

# Assign the route table subnet private 
resource "aws_route_table_association" "subnet-rt-association-db-a" {

  subnet_id      = aws_subnet.subnet-db-a.id
  route_table_id = aws_route_table.rt-db.id
}

# Assign the public route table to the redshift Subnet az2 for IGW 
resource "aws_route_table_association" "subnet-rt-association-db-b" {

  subnet_id      = aws_subnet.subnet-db-b.id
  route_table_id = aws_route_table.rt-db.id
}


#################### Subnet Lambda ####################

# Create the private Subnet
resource "aws_subnet" "subnet-lambda-a" {

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet_7_cidr
  availability_zone = data.aws_availability_zones.available.names[0]

  lifecycle {
    ignore_changes = [map_customer_owned_ip_on_launch, enable_lni_at_device_index, tags] # Ignora mudanças em certos atributos
  }

  tags = merge(var.common_tags, {
    Name = "${var.organization_name}-${var.environment}-priv-lambda-a"
  })

}

# Create the private Subnet
resource "aws_subnet" "subnet-lambda-b" {

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet_8_cidr
  availability_zone = data.aws_availability_zones.available.names[1]

  lifecycle {
    # prevent_destroy = true    # Impede que o recurso seja destruído
    ignore_changes = [map_customer_owned_ip_on_launch, enable_lni_at_device_index, tags] # Ignora mudanças em certos atributos
  }

  tags = merge(var.common_tags, {
    Name = "${var.organization_name}-${var.environment}-priv-lambda-b"
  })


}

# Define the private route table 
resource "aws_route_table" "rt-lambda" {

  vpc_id = aws_vpc.vpc.id

  # route to NATGW
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }

  # REFATORAR
  # route {
  #   cidr_block                = var.redshift_vpc_cidr
  #   vpc_peering_connection_id = data.aws_vpc_peering_connections.peering_connections.ids[0]
  # }


  tags = merge(var.common_tags, {
    Name = "${var.organization_name}-${var.environment}-rt-priv-lambda"

  })
}

# Assign the route table subnet private 
resource "aws_route_table_association" "subnet-rt-association-lambda-a" {

  subnet_id      = aws_subnet.subnet-lambda-a.id
  route_table_id = aws_route_table.rt-lambda.id
}

# Assign the public route table to the redshift Subnet az2 for IGW 
resource "aws_route_table_association" "subnet-rt-association-lambda-b" {

  subnet_id      = aws_subnet.subnet-lambda-b.id
  route_table_id = aws_route_table.rt-lambda.id
}

# Elastic IP para o NAT Gateway
resource "aws_eip" "nat" {

  domain = "vpc"

  tags = merge(var.common_tags, {
    Name = "${var.organization_name}-${var.environment}-nat-eip"
  })

}

# Criando o NAT Gateway
resource "aws_nat_gateway" "nat" {

  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.subnet-dmz-a.id

  tags = merge(var.common_tags, {
    Name = "${var.organization_name}-${var.environment}-nat-gateway"
  })
  depends_on = [aws_internet_gateway.igw, aws_subnet.subnet-dmz-a]
}


# resource "aws_security_group" "lambda-sg" {
#   name        = "vpc-endpoint-secretmanager-sg"
#   description = "Allow HTTPS traffic for Secrets Manager VPC Endpoint"
#   vpc_id      = aws_vpc.vpc.id

#   # Regras de Entrada
#   ingress {
#     description = "Allow HTTPS from private subnet"
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = [var.vpc_cidr] # Substitua pelo CIDR da sua sub-rede privada
#   }

#   # Regras de Saída
#   egress {
#     description = "Allow all outbound traffic"
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = merge(var.common_tags, {
#     Name = "${var.organization_name}-${var.environment}-lambda-sg"
#     Env    = var.environment
#   })

# }


#################### VPC Endpoints ####################

# resource "aws_security_group" "vpc_endpoint_secretmanager" {
#   name        = "${var.organization_name}-${var.environment}-secretmanager-sg"
#   description = "Allow HTTPS traffic for Secrets Manager VPC Endpoint"
#   vpc_id      = aws_vpc.vpc.id

#   # Regras de Entrada
#   ingress {
#     description = "Allow HTTPS from private subnet"
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = [var.vpc_cidr] # Substitua pelo CIDR da sua sub-rede privada
#   }

#   # Regras de Saída
#   egress {
#     description = "Allow all outbound traffic"
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = merge(var.common_tags, {
#     Name = "${var.organization_name}-${var.environment}-vpc-secretmanager-sg"
#   })
# }


# # Create a VPC Endpoint to secretsmanager service
# resource "aws_vpc_endpoint" "secretmanager" {

#   vpc_id              = aws_vpc.vpc.id
#   service_name        = "com.amazonaws.${var.region}.secretsmanager"
#   private_dns_enabled = true
#   vpc_endpoint_type   = "Interface"

#   security_group_ids = [
#     aws_security_group.vpc_endpoint_secretmanager.id
#   ]

#   subnet_ids = [
#     aws_subnet.subnet-lambda-a.id,
#     aws_subnet.subnet-lambda-b.id
#   ]

#   tags = merge(var.common_tags, {
#     Name = "${var.organization_name}-${var.environment}-secretmanager-endpoint"
#   })

#   depends_on = [ aws_subnet.subnet-lambda-a, aws_subnet.subnet-lambda-b, aws_security_group.vpc_endpoint_secretmanager ]
# }


# resource "aws_security_group" "lambda_security_group" {
#   name        = "${var.organization_name}-${var.environment}-lambda-sg"
#   description = "Security group for Lambda functions"
#   vpc_id      = aws_vpc.vpc.id

#   # Regras de Entrada 
#   # ingress {
#   #   description = "Allow HTTPS from private subnet"
#   #   from_port   = 443
#   #   to_port     = 443
#   #   protocol    = "tcp"
#   #   cidr_blocks = ["0.0.0.0/0"] # REFATORAR
#   # }

#   # Regras de Entrada
#   ingress {
#     description = "Allow Redshift from private subnet"
#     from_port   = 5439
#     to_port     = 5439
#     protocol    = "tcp"
#     cidr_blocks = [var.vpc_cidr]
#   }

#   # Regras de Entrada
#   ingress {
#     description     = "Allow HTTPS from private subnet"
#     from_port       = 443
#     to_port         = 443
#     protocol        = "tcp"
#     security_groups = [aws_security_group.vpc_endpoint_secretmanager.id]
#   }

#   # Regras de Saída
#   egress {
#     description = "Allow all outbound traffic"
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = merge(var.common_tags, {
#     Name = "${var.organization_name}-${var.environment}-vpc-lambda-sg"

#   })

#   lifecycle {
#     create_before_destroy = true
#   }
# }


# REFATORAR
# resource "aws_vpc_peering_connection" "connect_virginia_oregon" {
#   vpc_id        = aws_vpc.vpc.id
#   peer_vpc_id   = var.redshift_vpc_id 
#   peer_region   = "us-east-1"  #REFATORAR Região do Redshift

#   tags = merge(var.common_tags, {
#     Name = "${var.organization_name}-${var.environment}-vpc-peering-virginia-oregon"
#     
#   })
# }

# resource "aws_vpc_peering_connection_options" "connect_virginia_oregon" {
#   vpc_peering_connection_id = aws_vpc_peering_connection.connect_virginia_oregon.id

#   requester {
#     allow_remote_vpc_dns_resolution = true
#   }
# }

