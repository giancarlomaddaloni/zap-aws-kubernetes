locals {

  project_name   = "corbie"
  region         = "us-east-1"
  vpc_cidr       = "10.0.0.0/16"
  vpc_name       = "corbie-vpc"
  azs            = slice(data.aws_availability_zones.available.names, 0, 3)


  hosted_zone    = "corbietechnology.com"
  domain_name    = "corbietechnology.com"

  repositories = [
    "corbie-lb-eks",
    "corbie-cert-manager/startupapicheck",
    "corbie-cert-manager/acmesolver",
    "corbie-cert-manager/cainjector",
    "corbie-cert-manager/controller",
    "corbie-cert-manager/webhook",
    "stefanprodan/podinfo",
    "zaproxy/zaproxy",
    "fluxcd/flagger-loadtester",
    "swaggerapi/swagger-ui",
    "bitnami/metrics-server",
    "amazon/appmesh-controller",
    "aws-appmesh-envoy",
    "aws-appmesh-proxy-route-manager",
    "xray/aws-xray-daemon"

  ]


  k8s_parameters = {
    cluster_name = "${local.project_name}-eks"
  }


}