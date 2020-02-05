# === Security Group ===
resource "aws_security_group" "eks_cluster" {
  name   = "${var.name}-cluster"
  vpc_id = aws_vpc.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-cluster"
  }
}

# === EKS ===
resource "aws_eks_cluster" "eks_cluster" {
  name     = var.name
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    security_group_ids = [
      aws_security_group.eks_cluster.id
    ]
    subnet_ids = aws_subnet.private_subnet[*].id
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_cluster_policy,
    aws_iam_role_policy_attachment.eks_cluster_service_policy,
  ]
}

resource "aws_eks_node_group" "eks_cluster" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.name}-ng"
  node_role_arn   = aws_iam_role.eks_cluster_node_group.arn
  subnet_ids      = aws_subnet.private_subnet[*].id

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_node_policy,
    aws_iam_role_policy_attachment.eks_cluster_cni_policy,
    aws_iam_role_policy_attachment.eks_cluster_registry_policy
  ]
  instance_types = ["t3.large"]
}
