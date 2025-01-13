# VPC and Network Components
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = ">= 5.13.0"

  name = "eks-vpc-${var.environment}"
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Environment = var.environment
    Terraform   = "true"
    "kubernetes.io/cluster/eks-cluster-${var.account}-${var.environment}" = "shared"
  }
public_subnet_tags = {
    "kubernetes.io/cluster/eks-cluster-${var.account}-${var.environment}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/eks-cluster-${var.account}-${var.environment}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}
