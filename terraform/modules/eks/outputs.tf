output "cluster_id" {
  description = "EKS cluster ID"
  value = aws_eks_cluster.cluster.id
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value = aws_eks_cluster.cluster.arn
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value = aws_eks_cluster.cluster.endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value = aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value = aws_eks_cluster.cluster.certificate_authority[0].data
}

output "vpc_id" {
  description = "VPC ID"
  value = aws_vpc.eks_vpc.id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value = aws_subnet.public[*].id
}
