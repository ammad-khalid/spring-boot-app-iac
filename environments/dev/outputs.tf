# View Outputs of important variables and infrastucture components
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.name
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "cidr" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}
output "cluster_name" {
  description = "EKS Cluster Name"
  value       = module.eks.cluster_name

}

# Outputs
output "admin_role_arn" {
  value = aws_iam_role.eks_admin.arn
}

output "bastion_public_ip" {
  description = "Public IP address of the bastion host"
  value       = aws_eip.bastion.public_ip
}

output "role_arn" {
  description = "The IAM role ARN used by the EKS node group."
  value       = aws_iam_role.eks_node_group.arn
}