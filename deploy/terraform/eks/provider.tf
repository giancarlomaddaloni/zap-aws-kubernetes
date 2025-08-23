provider "aws" {
  region = local.region

  default_tags {
    tags = {
      Application  = "zap-zap"
      IaCTool      = "github-actions"
      DeployedBy   = "gmaddaloni"
      Repository   = "https://github.com/giancarlomaddaloni/zap-aws-kubernetes"
      Region       = local.region
    }
  }
}