# AWS Academy: roles IAM não podem ser criadas, então usamos a LabRole existente.
data "aws_iam_role" "lab" {
  name = "LabRole"
}

resource "aws_eks_cluster" "main" {
  name     = "${var.project_name}-cluster"
  role_arn = data.aws_iam_role.lab.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = concat(var.public_subnet_ids, var.private_subnet_ids)
    endpoint_public_access  = true
    endpoint_private_access = true
  }
}

resource "aws_launch_template" "nodes" {
  name_prefix = "${var.project_name}-nodes-"

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # IMDSv2
    http_put_response_hop_limit = 2
  }

  # default_tags do provider não chegam nas EC2 criadas pelo node group: tagueamos aqui (FinOps).
  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, { Name = "${var.project_name}-node" })
  }
  tag_specifications {
    resource_type = "volume"
    tags          = var.tags
  }
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-nodes"
  node_role_arn   = data.aws_iam_role.lab.arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = var.instance_types
  capacity_type   = var.capacity_type

  scaling_config {
    min_size     = var.min_nodes
    desired_size = var.desired_nodes
    max_size     = var.max_nodes
  }

  launch_template {
    id      = aws_launch_template.nodes.id
    version = aws_launch_template.nodes.latest_version
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}
