locals {
  iam_role_arn       = data.terraform_remote_state.infra_local.outputs.iam_eks_role_arn
  ecr_repository_url = data.terraform_remote_state.infra_local.outputs.ecr_repository_url
  branch             = replace(trim(substr(lower(var.branch), 0, 60), "-"), "/", "-")
  namespace          = "${var.app_name}-${local.branch}"
  host               = var.domain_name
  hostname           = "${local.branch}-${var.app_name}-${local.host}"
  acm_arn            = data.terraform_remote_state.infra_local.outputs.acm_arn
}

data "aws_lb_target_group" "this" {
  count = local.branch == "main" ? 1 : 0
  name  = "${var.app_name}-${local.cluster_name}"
}

resource "helm_release" "app" {
  name             = trim(substr(var.app_name, 0, 53), "-")
  repository       = "https://dnd-it.github.io/helm-charts"
  chart            = "webapp"
  version          = "1.6.0"
  namespace        = coalesce(local.namespace, data.terraform_remote_state.infra_local.outputs.k8s_namespace)
  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  wait             = true
  max_history      = 3

  values = [
    <<EOF
    # https://github.com/DND-IT/helm-charts/blob/main/charts/webapp/values.yaml

    aws_iam_role_arn: ${local.iam_role_arn}
    image_repo: ${local.ecr_repository_url}
    image_tag: ${var.image_tag}

    service:
      targetPort: 8080 # Port on which the application is exposed to

    scale:
      enabled: ${var.helm_enable_scaling}
      minReplicas: 3 # Minimum number of replicas, applied only if scaling is enabled
      maxReplicas: 20
      minAvailable: 60%
      cpuThresholdPercentage: 80

    metadata:
      deploymentAnnotations:
        ${yamlencode(var.helm_deployment_annotations)}

    probe:
      liveness: ${var.app_health_check_path}
      readiness: ${var.app_health_check_path}

    env:
      ${yamlencode(var.helm_env_vars)}

    externalSecrets:
      secretNames:
        %{for secret in var.helm_external_secrets~}
        - ${secret}
        %{endfor~}

    targetGroupBinding:
      enabled: ${local.branch == "main" ? "true" : "false"}
      targetGroupARN: ${local.branch == "main" ? data.aws_lb_target_group.this[0].arn : " "}

    ingress:
      enabled: ${local.branch != "main" ? true : false}
      className: alb
      annotations:
        alb.ingress.kubernetes.io/scheme: internet-facing
        alb.ingress.kubernetes.io/target-type: ip
        alb.ingress.kubernetes.io/group.name: ${var.app_name}
        alb.ingress.kubernetes.io/listen-ports: '[{"HTTP":80,"HTTPS":443}]'
        alb.ingress.kubernetes.io/ssl-redirect: '443'
        alb.ingress.kubernetes.io/healthcheck-path: ${var.app_health_check_path}
        alb.ingress.kubernetes.io/ssl-policy: ELBSecurityPolicy-TLS13-1-2-2021-06
        alb.ingress.kubernetes.io/certificate-arn: ${local.acm_arn}
        alb.ingress.kubernetes.io/load-balancer-attributes: deletion_protection.enabled=false
      hosts:
        - ${local.hostname}
      paths:
        - /

    nodeSelector:
      kubernetes.io/arch: amd64
    EOF
  ]
  dynamic "set" {
    for_each = var.helm_set
    content {
      name  = set.key
      value = set.value
      type  = optional(string)
    }
  }

}
