module "zap_efs" {

  source  = "terraform-aws-modules/efs/aws"
  version = "1.8.0"

  # File system
  name           = "${local.project_name}-efs"
  creation_token = "${local.project_name}-efs-token"
  encrypted      = true

  lifecycle_policy = {
    transition_to_ia = "AFTER_90_DAYS"
  }

  # File system policy
  attach_policy                      = false
  bypass_policy_lockout_safety_check = false

  # Mount targets / security group
  mount_targets = {
    "us-east-1a" = {
      subnet_id = module.zap_vpc.private_subnets[0]
    }
    "us-east-1b" = {
      subnet_id = module.zap_vpc.private_subnets[1]
    }
    "us-east-1c" = {
      subnet_id = module.zap_vpc.private_subnets[2]
    }
  }
  security_group_description = "EFS zap SG"
  security_group_vpc_id      = module.zap_vpc.vpc_id
  security_group_name        = "${local.project_name}-efs-sg"
  security_group_rules = {
    vpc = {
      description = "NFS ingress from VPC private subnets for zap"
      cidr_blocks = ["${local.vpc_cidr}"]
    }
  }

  # Access point(s)
  access_points = {
    zap_zap = {
      root_directory = {
        path = "/zap"
        creation_info = {
          owner_gid   = 1001
          owner_uid   = 1001
          permissions = "755"
        }
      }
    }
  }

  # Backup policy
  enable_backup_policy = false

  # Replication configuration
  create_replication_configuration = false
}
