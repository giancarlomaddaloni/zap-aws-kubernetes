data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}

data "aws_vpc" "zap" {
  filter {
    name   = "tag:Name"
    values = [local.vpc_name]
  }
}


data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.zap.id]
  }

  filter {
    name   = "tag:Name"
    values = ["zap-private-*"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.zap.id]
  }

  filter {
    name   = "tag:Name"
    values = ["zap-public-*"]
  }
}


data "aws_default_tags" "zap" {}
