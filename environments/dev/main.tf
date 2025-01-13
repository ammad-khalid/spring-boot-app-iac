# # Resource Creation
# # Security Group for Bastion Host

# Data sources to get EKS cluster info
data "aws_eks_cluster" "cluster" {
  name = "eks-cluster-${var.account}-${var.environment}"
    # Add explicit dependency
  depends_on = [null_resource.eks_ready]
}

data "aws_eks_cluster_auth" "cluster" {
  name = "eks-cluster-${var.account}-${var.environment}"
    # Add explicit dependency
  depends_on = [null_resource.eks_ready]
}

resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = "3.11.0"  # Adjust version as needed

  set {
    name  = "metrics.enabled"
    value = "true"
  }

  set {
    name  = "args[0]"
    value = "--kubelet-insecure-tls"
  }
}

resource "aws_security_group" "bastion" {
  name_prefix = "bastion-sg-"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict to your IP or CIDR for security
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion-sg"
  }
}

#Bastion Host (EC2 instance in the public subnet)
resource "aws_instance" "bastion" {
  ami                         = var.bastion_ami
  instance_type               = var.instance_type_bastion
  key_name                    = var.key_name
  subnet_id                   = module.vpc.public_subnets[0] # Use the first public subnet
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  associate_public_ip_address = true

  tags = {
    Name = "bastion-host"
  }
  depends_on = [module.vpc]
}

resource "aws_eip" "bastion" {
  instance = aws_instance.bastion.id
   
  domain   = "vpc"

  tags = {
    Name = "bastion-eip"
  }
}
# #IAM Roles and Policies for EKS

resource "aws_iam_role" "bastion_role" {
  name = "bastion-eks-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "bastion_eks_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.bastion_role.name
}

resource "aws_iam_role_policy" "bastion_eks_access" {
  name = "bastion-eks-access-policy"
  role = aws_iam_role.bastion_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}
