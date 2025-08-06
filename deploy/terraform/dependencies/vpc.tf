
module "corbie_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.0.1"

  name = local.vpc_name
  cidr = local.vpc_cidr

  azs                 = local.azs
  private_subnets     = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  public_subnets      = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 4)]


  private_subnet_names = [
    for i, az in local.azs : "${local.project_name}-private-${lower(substr("abcdefg", i, 1))}"
  ]

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.k8s_parameters.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"                            = "1"
  }


  public_subnet_names = [
    for i, az in local.azs : "${local.project_name}-public-${lower(substr("abcdefg", i, 1))}"
  ]

  
  public_subnet_tags = {
    "kubernetes.io/cluster/${local.k8s_parameters.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                                     = "1"
  }


  create_database_subnet_group  = false
  manage_default_network_acl    = false
  manage_default_route_table    = false
  manage_default_security_group = false


  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway = true
  single_nat_gateway = true
  create_private_nat_gateway_route = true
  create_igw = true

  enable_vpn_gateway = false
  enable_dhcp_options = true

}