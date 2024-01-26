resource "aws_iam_policy" "efs_csi_policy" {
  name_prefix = "efs-csi-driver-policy"
  policy      = data.aws_iam_policy_document.efs_csi_policy_doc.json
}

module "efs_csi_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.33.1"
  create_role                   = true
  role_description              = "EFS CSI Driver Role"
  role_name_prefix              = "efs-csi-driver-policy"
  provider_url                  = var.oidc_provider_url
  role_policy_arns              = [aws_iam_policy.efs_csi_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.efs_csi_namespace}:${var.efs_csi_sa_name}"]
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

  set {
    name  = "image.repository"
    value = var.efs_csi_helm_image_repository
    type  = "string"
  }

  set {
    name  = "controller.serviceAccount.create"
    value = "true"
    type  = "string"
  }

  set {
    name  = "controller.serviceAccount.name"
    value = var.efs_csi_sa_name
    type  = "string"
  }

  set {
    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.efs_csi_role.iam_role_arn
    type  = "string"
  }
}
