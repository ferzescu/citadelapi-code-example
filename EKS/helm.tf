data "aws_caller_identity" "current" {} 

data "aws_region" "current" {}

locals {
  k8s_service_account_namespace = "kube-system"
  k8s_service_account_name      = "cluster-autoscaler-aws"
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

resource "helm_release" "cluster-autoscaler" {
  depends_on = [
    module.eks
  ]

  name             = "cluster-autoscaler"
  namespace        = local.k8s_service_account_namespace
  repository       = "https://kubernetes.github.io/autoscaler"
  chart            = "cluster-autoscaler"
  version          = "9.10.7"
  create_namespace = false

  set {
    name  = "awsRegion"
    value = data.aws_region.current.name
  }
  set {
    name  = "rbac.serviceAccount.name"
    value = local.k8s_service_account_name
  }
  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.iam_assumable_role_admin.iam_role_arn
    type  = "string"
  }
  set {
    name  = "autoDiscovery.clusterName"
    value = local.name
  }
  set {
    name  = "autoDiscovery.enabled"
    value = "true"
  }
  set {
    name  = "rbac.create"
    value = "true"
  }
}

resource "helm_release" "ingress-nginx" {
  depends_on = [
    module.eks
  ]

  name             = "ingress-nginx"
  namespace        = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.0.13"
  create_namespace = true
}

resource "helm_release" "cert-manager" {
  depends_on = [
    module.eks,
    helm_release.ingress-nginx
  ]

  name             = "cert-manager"
  namespace        = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  create_namespace = true

  set {
    name  = "version"
    value = "v1.4.0"
  }
  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "helm_release" "elasticsearch-testnet" {
  depends_on = [
    module.eks
  ]

  name             = "testnet"
  namespace        = "testnet"
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "elasticsearch"
  version          = "17.7.0"
  create_namespace = true

  values = [
    "${file("./helm_values/es.yaml")}"
  ]
}

resource "helm_release" "elasticsearch-mainnet" {
  depends_on = [
    module.eks
  ]

  name             = "mainnet"
  namespace        = "mainnet"
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "elasticsearch"
  version          = "17.7.0"
  create_namespace = true

  values = [
    "${file("./helm_values/es.yaml")}"
  ]
}

resource "helm_release" "elasticsearch-stage" {
  depends_on = [
    module.eks
  ]

  name             = "stage"
  namespace        = "stage"
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "elasticsearch"
  version          = "17.7.0"
  create_namespace = true

  values = [
    "${file("./helm_values/es.yaml")}"
  ]
}

resource "helm_release" "elasticsearch-develop" {
  depends_on = [
    module.eks
  ]

  name             = "develop"
  namespace        = "develop"
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "elasticsearch"
  version          = "17.7.0"
  create_namespace = true

  values = [
    "${file("./helm_values/es.yaml")}"
  ]
}

module "iam_assumable_role_admin" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 4.0"

  create_role                   = true
  role_name                     = "cluster-autoscaler"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.cluster_autoscaler.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.k8s_service_account_namespace}:${local.k8s_service_account_name}"]
}

resource "aws_iam_policy" "cluster_autoscaler" {
  name_prefix = "cluster-autoscaler"
  description = "EKS cluster-autoscaler policy for cluster ${module.eks.cluster_id}"
  policy      = data.aws_iam_policy_document.cluster_autoscaler.json
}

data "aws_iam_policy_document" "cluster_autoscaler" {
  statement {
    sid    = "clusterAutoscalerAll"
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeLaunchTemplateVersions",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "clusterAutoscalerOwn"
    effect = "Allow"

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/${module.eks.cluster_id}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/enabled"
      values   = ["true"]
    }
  }
}
