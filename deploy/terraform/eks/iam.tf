module "disabled" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name   = "disabled"
  create_role = false
}

module "corbie_eks_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  allow_self_assume_role = true


  role_name = "${local.project_name}-eks-sa"

  oidc_providers = {
    default = {
      provider_arn               = module.corbie_eks.oidc_provider_arn
      namespace_service_accounts = ["default:kube-system", "default:corbie-sa", "corbie:corbie-sa"]
    }
  }

  role_policy_arns = {
    AmazonEKS_CNI_Policy = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    additional           = aws_iam_policy.additional.arn
    ssmInstance          = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  depends_on = [module.corbie_eks] 
}

module "corbie_sa_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  allow_self_assume_role = true


  role_name = "${local.project_name}-sa"

  oidc_providers = {
    default = {
      provider_arn               = module.corbie_eks.oidc_provider_arn
      namespace_service_accounts = ["default:kube-system", "default:corbie-sa", "corbie:corbie-sa"]
    }
  }

  role_policy_arns = {
    corbie_sa           = aws_iam_policy.corbie_sa.arn
  }

  depends_on = [module.corbie_eks] 

}


resource "aws_iam_policy" "corbie_sa" {
  name        = "${local.project_name}_eks_sa"
  description = "Additional test policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { 
        Action = [
          "s3:*"
        ]
        Effect = "Allow"
        Resource = "*"
        Sid = "S3Access"
      }
  ]})
}


resource "aws_iam_policy" "additional" {
  name        = "${local.project_name}_eks_main_role_policy"
  description = "Additional test policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Sid = "ECR"
        Effect   = "Allow"
        Resource = "*"
      },
      { 
        Action = [
          "sts:AssumeRole",
          "sts:GetCallerIdentity"
        ]
        Effect = "Allow"
        Sid = "AssumeRole"
        Resource = "*"
      },   
      { 
        Action = [
          "s3:ListAllMyBuckets"
        ]
        Effect = "Allow"
        Resource = "*"
        Sid = "ListAllS3"
      },
      {
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Effect = "Allow"
        Resource = "*"
        Sid = "KMS"
      }  
  ]})
}

################################################################################
# SPECIFIC IRSA Roles
################################################################################


module "corbie_lb_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                              = "${local.project_name}-lb-sa"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.corbie_eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}


module "corbie_efs_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                              = "${local.project_name}-efs-sa"
  attach_efs_csi_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.corbie_eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:efs-sa", "corbie:efs-sa", "corbie:mongodb"]
    }
  }
}

################################################################################
# EKS EC2 Managed Nodes Roles
################################################################################


resource "aws_iam_role" "corbie_eks_node_role" {
  name = local.k8s_parameters.iam_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

}

resource "aws_iam_role_policy_attachment" "node_eks_worker" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.corbie_eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "node_ecr_readonly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.corbie_eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "node_cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.corbie_eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "node_ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.corbie_eks_node_role.name
}