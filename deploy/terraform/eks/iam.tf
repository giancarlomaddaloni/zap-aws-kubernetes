
module "corbie_eks_role" {
  source    = "../modules/iam-role-for-service-accounts"
  # allow_self_assume_role = true


  name = "${local.project_name}-eks-sa"

  oidc_providers = {
    default = {
      provider_arn               = module.corbie_eks.oidc_provider_arn
      namespace_service_accounts = ["default:kube-system", "default:corbie-sa", "corbie:corbie-sa"]
    }
  }

  policies = {
    AmazonEKS_CNI_Policy = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    corbie_s3_sa         = aws_iam_policy.corbie_s3_sa.arn
    corbie_ecr_sa        = aws_iam_policy.corbie_ecr_sa.arn
    ssmInstance          = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  depends_on = [module.corbie_eks] 
}

module "corbie_sa_role_zap" {
  source    = "../modules/iam-role-for-service-accounts"
  # allow_self_assume_role = true


  name = "${local.project_name}-zap-sa"

  oidc_providers = {
    default = {
      provider_arn               = module.corbie_eks.oidc_provider_arn
      namespace_service_accounts = ["default:corbie-sa", "kube-system:corbie-sa", "corbie:corbie-sa", "zap-demo:corbie-sa", "appmesh-system:corbie-sa"]
    }
  }


  policies = {
    corbie_s3_sa           = aws_iam_policy.corbie_s3_sa.arn
    corbie_ecr_sa          = aws_iam_policy.corbie_ecr_sa.arn
  }

  depends_on = [module.corbie_eks] 

}

module "corbie_sa_role_ptest" {
  source    = "../modules/iam-role-for-service-accounts"
  # allow_self_assume_role = true


  name = "${local.project_name}-zap-sa"

  oidc_providers = {
    default = {
      provider_arn               = module.corbie_eks.oidc_provider_arn
      namespace_service_accounts = [
        "default:corbie-sa", 
        "kube-system:corbie-sa", 
        "corbie:corbie-ptest-sa", 
        "appmesh-system:corbie-ptest-sa", 
        "testkube:agent-sa-testkube-runner", 
        "testkube:exec-sa-testkube-runner"
      ]
    }
  }

  policies = {
    corbie_s3_sa           = aws_iam_policy.corbie_s3_sa.arn
    corbie_ecr_sa          = aws_iam_policy.corbie_ecr_sa.arn
  }


  depends_on = [module.corbie_eks] 

}


resource "aws_iam_policy" "corbie_s3_sa" {
  name        = "${local.project_name}_eks_s3_policy_sa"
  description = "S3 Full Access Policy"

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


resource "aws_iam_policy" "corbie_ecr_sa" {
  name        = "${local.project_name}_eks_ecr_policy_sa"
  description = "ECR Access Policy"

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
  source    = "../modules/iam-role-for-service-accounts"

  name                                   = "${local.project_name}-lb-sa"
  attach_load_balancer_controller_policy = true
  

  oidc_providers = {
    ex = {
      provider_arn               = module.corbie_eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}



module "corbie_efs_role" {
  source    = "../modules/iam-role-for-service-accounts"

  name                              = "${local.project_name}-efs-sa"
  attach_efs_csi_policy             = true

  oidc_providers = {
    ex = {
      provider_arn               = module.corbie_eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:efs-sa", "kube-system:efs-csi-controller-sa", "zap-demo:efs-csi-controller-sa", "kube-system:efs-csi-node-sa", "appmesh-system:efs-csi-controller-sa","testkube:efs-csi-controller-sa"]
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