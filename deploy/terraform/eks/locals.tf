locals {
  project_name   = "corbie"
  region         = "us-east-1"
  vpc_cidr       = "10.0.0.0/16"
  vpc_name       = "corbie-vpc"


  k8s_parameters = {
    cluster_name = "${local.project_name}-eks"
    version = "1.32"
    namespace_access = ["default", "kube-system", "zap-demo", "kube-public", "kube-node-lease", "cert-manager", "istio-system", "aws-observability"]
    instance_types = ["t3a.small"]
    capacity_type  = "ON_DEMAND"
    cluster_service_cidr = "172.20.0.0/16"
    min_size     = 1
    max_size     = 4
    desired_size = 2
    node_group_name = "${local.project_name}-node-group"
    iam_role_name   = "${local.project_name}-eks-node-role"

  }

  tags = {

  }

}