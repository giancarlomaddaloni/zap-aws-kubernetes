module "cluster_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  name        = "${local.project_name}-cluster-sg"
  vpc_id      = data.aws_vpc.corbie.id
  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port                = 0
      to_port                  = 0
      protocol                 = -1
      cidr_blocks = local.vpc_cidr
    },
    {
      from_port                = 443
      to_port                  = 443
      protocol                 = -1
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  # egress
  egress_with_cidr_blocks = [
    {
      from_port                = 0
      to_port                  = 0
      protocol                 = -1
      cidr_blocks              = "0.0.0.0/0"
    }
  ]
}

module "alb_sg" {

  source      = "terraform-aws-modules/security-group/aws"
  name        = "${local.project_name}-alb-sg"
  vpc_id      = data.aws_vpc.corbie.id


  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port                = 0
      to_port                  = 0
      protocol                 = -1
      cidr_blocks              = local.vpc_cidr
    },
  ]

  # egress
  egress_with_cidr_blocks = [
    {
      from_port                = 0
      to_port                  = 0
      protocol                 = -1
      cidr_blocks              = local.vpc_cidr
    },
  ]

}