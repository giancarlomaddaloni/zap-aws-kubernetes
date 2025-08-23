locals {

  project_name   = "zap"
  region         = "us-east-1"
  vpc_cidr       = "10.0.0.0/16"
  vpc_name       = "zap-vpc"
  azs            = slice(data.aws_availability_zones.available.names, 0, 3)


  hosted_zone    = "zaptechnology.com"
  domain_name    = "zaptechnology.com"

  repositories = [
    "zap-lb-eks",
    "zap-cert-manager/startupapicheck",
    "zap-cert-manager/acmesolver",
    "zap-cert-manager/cainjector",
    "zap-cert-manager/controller",
    "zap-cert-manager/webhook",
    "stefanprodan/podinfo",
    "zaproxy/zaproxy",
    "fluxcd/flagger-loadtester",
    "swaggerapi/swagger-ui",
    "bitnami/metrics-server",
    "amazon/appmesh-controller",
    "aws-appmesh-envoy",
    "aws-appmesh-proxy-route-manager",
    "xray/aws-xray-daemon",
    "prom/prometheus",
    "fluxcd/flagger",
    "grafana/grafana",
    "kubeshop/testkube-api-server",
    "kubeshop/testkube-tw-toolkit",
    "kubeshop/testkube-tw-init"
  ]




  k8s_parameters = {
    cluster_name = "${local.project_name}-eks"
  }


}