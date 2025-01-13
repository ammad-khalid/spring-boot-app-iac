locals {
  # EKS cluster ARN pattern
  cluster_arn = "arn:aws:eks:${var.region}:${data.aws_caller_identity.current.account_id}:cluster/eks-cluster-${var.account}-${var.environment}"
}

#################################################
# EKS Cluster Admin Role
#################################################
resource "aws_iam_role" "eks_admin" {
  name = "eks-cluster-admin"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
      }
    ]
  })

  tags = merge( { Role = "EKSAdmin" })
}

resource "aws_iam_policy" "eks_admin" {
  name        = "eks-cluster-admin-policy"
  description = "Admin access policy for EKS cluster"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:*",
          "ec2:DescribeInstances",
          "ec2:DescribeRouteTables",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs",
          "iam:ListRoles",
          "iam:GetRole",
          "cloudformation:ListStacks",
          "cloudformation:DescribeStacks"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "eks:AccessKubernetesApi",
          "eks:DescribeCluster"
        ]
        Resource = local.cluster_arn
      }
    ]
  })
}

# Kubernetes RBAC Configuration
resource "kubernetes_cluster_role_binding" "admin_users" {
  metadata {
    name = "eks-admin-group"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "Group"
    name      = "eks-admin-group"
    api_group = "rbac.authorization.k8s.io"
  }
}

# Policy attachments
resource "aws_iam_role_policy_attachment" "eks_admin" {
  policy_arn = aws_iam_policy.eks_admin.arn
  role       = aws_iam_role.eks_admin.name
}

# Data sources
data "aws_caller_identity" "current" {}