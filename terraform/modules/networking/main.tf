# Networking Module - Production VPC for EKS
# High availability, security, and reliability

# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC
resource "aws_vpc" "cloudmart" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name                                        = "cloudmart-vpc-${var.environment}"
    "kubernetes.io/cluster/cloudmart-${var.environment}" = "shared"
    Environment = var.environment
    Type        = "vpc"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "cloudmart" {
  vpc_id = aws_vpc.cloudmart.id

  tags = merge(var.tags, {
    Name        = "cloudmart-igw-${var.environment}"
    Environment = var.environment
    Type        = "internet-gateway"
  })
}

# Public Subnets (for Load Balancers)
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.cloudmart.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name                                        = "cloudmart-public-${count.index + 1}-${var.environment}"
    "kubernetes.io/cluster/cloudmart-${var.environment}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
    Environment = var.environment
    Type        = "public-subnet"
    AZ          = data.aws_availability_zones.available.names[count.index]
  })
}

# Private Subnets (for EKS Worker Nodes)
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.cloudmart.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(var.tags, {
    Name                                        = "cloudmart-private-${count.index + 1}-${var.environment}"
    "kubernetes.io/cluster/cloudmart-${var.environment}" = "owned"
    "kubernetes.io/role/internal-elb"           = "1"
    Environment = var.environment
    Type        = "private-subnet"
    AZ          = data.aws_availability_zones.available.names[count.index]
  })
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count = length(var.public_subnet_cidrs)

  domain = "vpc"
  depends_on = [aws_internet_gateway.cloudmart]

  tags = merge(var.tags, {
    Name        = "cloudmart-nat-eip-${count.index + 1}-${var.environment}"
    Environment = var.environment
    Type        = "elastic-ip"
  })
}

# NAT Gateways (High Availability - one per AZ)
resource "aws_nat_gateway" "cloudmart" {
  count = length(var.public_subnet_cidrs)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(var.tags, {
    Name        = "cloudmart-nat-${count.index + 1}-${var.environment}"
    Environment = var.environment
    Type        = "nat-gateway"
  })

  depends_on = [aws_internet_gateway.cloudmart]
}

# Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.cloudmart.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cloudmart.id
  }

  tags = merge(var.tags, {
    Name        = "cloudmart-public-rt-${var.environment}"
    Environment = var.environment
    Type        = "route-table"
  })
}

# Route Table Associations for Public Subnets
resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Route Tables for Private Subnets (one per AZ for HA)
resource "aws_route_table" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id = aws_vpc.cloudmart.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.cloudmart[count.index].id
  }

  tags = merge(var.tags, {
    Name        = "cloudmart-private-rt-${count.index + 1}-${var.environment}"
    Environment = var.environment
    Type        = "route-table"
  })
}

# Route Table Associations for Private Subnets
resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# Security Group for EKS Control Plane
resource "aws_security_group" "eks_cluster" {
  name_prefix = "cloudmart-eks-cluster-${var.environment}"
  vpc_id      = aws_vpc.cloudmart.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name        = "cloudmart-eks-cluster-sg-${var.environment}"
    Environment = var.environment
    Type        = "security-group"
    Purpose     = "eks-control-plane"
  })
}

# Security Group for EKS Worker Nodes
resource "aws_security_group" "eks_nodes" {
  name_prefix = "cloudmart-eks-nodes-${var.environment}"
  vpc_id      = aws_vpc.cloudmart.id

  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port       = 1025
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_cluster.id]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_cluster.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name        = "cloudmart-eks-nodes-sg-${var.environment}"
    Environment = var.environment
    Type        = "security-group"
    Purpose     = "eks-worker-nodes"
  })
}
