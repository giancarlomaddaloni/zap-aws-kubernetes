module "corbie_eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.37.1"
  cluster_name    = local.k8s_parameters.cluster_name
  cluster_version = local.k8s_parameters.version
  cluster_security_group_id = module.cluster_sg.security_group_id
  cluster_endpoint_public_access  = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]
  enable_cluster_creator_admin_permissions = true
  control_plane_subnet_ids = data.aws_subnets.private.ids
  cluster_enabled_log_types = [ "audit", "api", "authenticator" ]
  cluster_addons = {
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {} 

  }

  vpc_id                   = data.aws_vpc.corbie.id
  subnet_ids               = data.aws_subnets.private.ids


  access_entries = {
    federated_giancarlo_maddaloni = {
      kubernetes_groups = [] 
      principal_arn     = "arn:aws:sts::593518286265:federated-user/GiancarloMaddaloni"
      policy_associations = {
        namespace = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
          access_scope = {
            namespaces = local.k8s_parameters.namespace_access
            type       = "namespace"
          }
        },
        cluster = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type       = "cluster"
          }
        }
      }
    },
    federated_rodrigo_espinoza = {
      kubernetes_groups = [] 
      principal_arn     = "arn:aws:sts::593518286265:federated-user/RodrigoEspinoza"
      policy_associations = {
        namespace = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
          access_scope = {
            namespaces = local.k8s_parameters.namespace_access
            type       = "namespace"
          }
        },
        cluster = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type       = "cluster"
          }
        }
      }
    },
    federated_terraform_deploy = {
      kubernetes_groups = [] 
      principal_arn     = "arn:aws:sts::593518286265:federated-user/terraform-deploy"
      policy_associations = {
        namespace = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
          access_scope = {
            namespaces = local.k8s_parameters.namespace_access
            type       = "namespace"
          }
        },
        cluster = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type       = "cluster"
          }
        }
      }
    },
    giancarlo_maddaloni = {
      kubernetes_groups = [] 
      principal_arn     = "arn:aws:iam::593518286265:user/GiancarloMaddaloni"
      policy_associations = {
        namespace = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
          access_scope = {
            namespaces = local.k8s_parameters.namespace_access
            type       = "namespace"
          }
        },
        cluster = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type       = "cluster"
          }
        }
      }
    },
    rodrigo_espinoza = {
      kubernetes_groups = [] 
      principal_arn     = "arn:aws:iam::593518286265:user/RodrigoEspinoza"
      policy_associations = {
        namespace = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
          access_scope = {
            namespaces = local.k8s_parameters.namespace_access
            type       = "namespace"
          }
        },
        cluster = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type       = "cluster"
          }
        }
      }
    }
  }


}

resource "aws_eks_addon" "coredns" {
  cluster_name = module.corbie_eks.cluster_name
  addon_name   = "coredns"
  addon_version = "v1.11.4-eksbuild.2"
  resolve_conflicts_on_create = "OVERWRITE"  
  
  depends_on = [
    module.corbie_eks,
    module.corbie_node_group
  ]
}



module "corbie_node_group" {
  source = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  version = "20.13.1"

  name            = local.k8s_parameters.node_group_name
  cluster_name    = local.k8s_parameters.cluster_name
  
  cluster_version = local.k8s_parameters.version

  subnet_ids   = data.aws_subnets.private.ids
  create_iam_role = false

  min_size     = local.k8s_parameters.min_size
  max_size     = local.k8s_parameters.max_size
  desired_size = local.k8s_parameters.desired_size

  iam_role_arn = aws_iam_role.corbie_eks_node_role.arn

  instance_types       = local.k8s_parameters.instance_types
  capacity_type        = local.k8s_parameters.capacity_type
  cluster_service_cidr = local.k8s_parameters.cluster_service_cidr

  launch_template_tags   = data.aws_default_tags.corbie.tags
  vpc_security_group_ids = [module.cluster_sg.security_group_id]

  labels = {
    "application" : "corbie"
  }

  depends_on = [
    module.corbie_eks
  ]
  
}