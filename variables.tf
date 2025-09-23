variable "efs_csi_namespace" {
  description = "The namespace the csi driver is deployed to."
  type        = string
  default     = "kube-system"
}

variable "efs_csi_sa_name" {
  description = "The service account name used for AWS EKS Container Storage Interface (CSI)"
  type        = string
  default     = "efs-csi-driver-sa"
}

variable "helm_chart_version" {
  description = "The version of the helm chart."
  type        = string
}

variable "efs_csi_helm_image_repository" {
  description = "The image repository of the region. I.e. 602401143452.dkr.ecr.eu-west-1.amazonaws.com/eks/aws-efs-csi-driver. See also https://docs.aws.amazon.com/eks/latest/userguide/add-ons-images.html"
  type        = string
}

variable "oidc_provider_arn" {
  description = "The arn of the openid connect provider."
  type        = string
}
