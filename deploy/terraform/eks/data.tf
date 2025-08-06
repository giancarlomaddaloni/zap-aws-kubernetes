data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}

data "aws_vpc" "corbie" {
  filter {
    name   = "tag:Name"
    values = [local.vpc_name]
  }
}


data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.corbie.id]
  }

  filter {
    name   = "tag:Name"
    values = ["corbie-private-*"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.corbie.id]
  }

  filter {
    name   = "tag:Name"
    values = ["corbie-public-*"]
  }
}


data "aws_default_tags" "corbie" {}
