# EKS Cluster Creation 

# IAM Role for EKS Managed Node Group
resource "null_resource" "eks_ready" {
  depends_on = [module.eks]
}

resource "aws_iam_role" "eks_node_group" {
  name = "eks-node-role-${var.account}-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach required policies to the IAM Role
resource "aws_iam_role_policy_attachment" "eks_node_group_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  ])

  role       = aws_iam_role.eks_node_group.name
  policy_arn = each.value
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = ">= 20.29.0"

  cluster_name                    = "eks-cluster-${var.account}-${var.environment}"
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = false
  cluster_version                 = var.eks_version
  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = module.vpc.private_subnets

  cluster_addons = {
    
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
    
  }
  enable_cluster_creator_admin_permissions = true
  enable_irsa                              = true

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
  eks_managed_node_groups = {
    eks-node-group = {
      name = "eks-${var.account}-${var.environment}"
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = var.instance_type
      disk_size      = var.disk_size
      min_size       = var.min_size
      max_size       = var.max_size
      desired_size   = var.desired_size               # variable name changed
      node_role  = aws_iam_role.eks_node_group.arn
    }
  }
}

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = jsonencode([
      {
        rolearn  = aws_iam_role.eks_node_group.arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = ["system:bootstrappers", "system:nodes"]
      },
      {
        rolearn  = "arn:aws:iam::${var.account_id}:role/EKS-Github-Actions"
        username = "cluster-admin"
        groups   = ["system:masters"]
      },
      {
        rolearn  = "arn:aws:iam::116981791371:role/AWSReservedSSO_AWSAdministratorAccess_f966aafc09b1d2a4"
        username = "cluster-admin"
        groups   = ["system:masters"]
      },
      {
        rolearn  = "arn:aws:iam::${var.account_id}:role/AWSReservedSSO_AWSDeveloperAccess_5f44808e5232ea5e"
        username = "cluster-admin"
        groups   = ["system:masters"]
      },
      {
        rolearn  = "arn:aws:iam::${var.account_id}:role/assume-role-github-integration"
        username = "assume-role-github-integration"
        groups   = ["system:masters"]
      },      
    ])
  }

  depends_on = [aws_iam_role.eks_node_group] # Ensure the node group is created first
}
