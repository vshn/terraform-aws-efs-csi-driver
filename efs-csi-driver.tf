resource "aws_iam_policy" "efs_csi_policy" {
  name_prefix = "efs-csi-driver-policy"
  policy      = data.aws_iam_policy_document.efs_csi_policy_doc.json
}

module "efs_csi_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version                       = "6.2.1"
  description                   = "EFS CSI Driver Role"
  name                          = "efs-csi-driver-policy"
  use_name_prefix               = true
  oidc_providers = {
    provider = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["${var.efs_csi_namespace}:${var.efs_csi_sa_name}"]
    }
  }
  policies = {
    efs_csi_policy = aws_iam_policy.efs_csi_policy.arn
  }
}

resource "helm_release" "efs_csi" {
  atomic          = true
  chart           = "aws-efs-csi-driver"
  cleanup_on_fail = true
  name            = "aws-efs-csi-driver"
  namespace       = var.efs_csi_namespace
  repository      = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
  timeout         = 300
  version         = var.helm_chart_version

  set = [
    {
      name  = "image.repository"
      value = var.efs_csi_helm_image_repository
      type  = "string"
    },
    {
      name  = "controller.serviceAccount.create"
      value = "true"
      type  = "string"
    },
    {
      name  = "controller.serviceAccount.name"
      value = var.efs_csi_sa_name
      type  = "string"
    },
    {
      name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = module.efs_csi_role.arn
      type  = "string"
    }
  ]
}
