// EKS
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-${var.eks_cluster_name}"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cluster_ClusterKMSAccessAttachment" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = aws_iam_policy.InlineEKSClusterNodesPolicyToAccessKMS.arn
}

resource "aws_iam_role" "eks_managed_nodes" {
  name = "eks-node-group-${var.eks_cluster_name}"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks_managed_nodes-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_managed_nodes.name
}

resource "aws_iam_role_policy_attachment" "eks_managed_nodes-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_managed_nodes.name
}

resource "aws_iam_role_policy_attachment" "eks_managed_nodes-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_managed_nodes.name
}

resource "aws_iam_role_policy_attachment" "eks_managed_nodes-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_managed_nodes.name
}

resource "aws_iam_role_policy_attachment" "eks_managed_nodes_NodesKMSAccessAttachment" {
  policy_arn = aws_iam_policy.InlineEKSClusterNodesPolicyToAccessKMS.arn
  role       = aws_iam_role.eks_managed_nodes.name
}

resource "aws_eks_cluster" "eks_cluster" {
  # checkov:skip=CKV_AWS_37:Ensure Amazon EKS control plane logging enabled for all log types aws_eks_cluster.eks_cluster
  # checkov:skip=CKV_AWS_58:Ensure EKS Cluster has Secrets Encryption Enable

  depends_on = [aws_iam_role.eks-master, aws_iam_role.eks-nodes, aws_security_group.eks_sg]

  name     = var.eks_cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = var.eks_version

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = false
    security_group_ids      = [aws_security_group.eks_sg.id]
    subnet_ids              = var.eks_private_subnet_ids
  }

}

resource "aws_eks_node_group" "eks_nodes" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "eks-node-group-${var.eks_cluster_name}"
  node_role_arn   = aws_iam_role.eks_managed_nodes.arn
  subnet_ids      = var.eks_private_subnet_ids

  disk_size      = var.eks_ec2_volume_size
  instance_types = [var.eks_node_type]

  scaling_config {
    desired_size = var.eks_min_capacity
    max_size     = var.eks_max_capacity
    min_size     = var.eks_min_capacity
  }

  remote_access {
    ec2_ssh_key               = var.eks_keypair_name
    source_security_group_ids = [aws_security_group.eks_sg_ssh.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_managed_nodes-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_managed_nodes-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks_managed_nodes-AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.eks_managed_nodes_NodesKMSAccessAttachment,
  ]
}

data "aws_eks_cluster_auth" "eks_cluster" {
  name = var.eks_cluster_name
}
