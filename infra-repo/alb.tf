# ###############################################################################
# # AWS Load Balancer Controller + IAM Resources
# ###############################################################################
# data "aws_iam_policy_document" "aws_lbc" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["pods.eks.amazonaws.com"]
#     }

#     actions = [
#       "sts:AssumeRole",
#       "sts:TagSession"
#     ]
#   }
# }

# resource "aws_iam_role" "aws_lbc" {
#   name               = "${module.eks.cluster_name}-aws-lbc"
#   assume_role_policy = data.aws_iam_policy_document.aws_lbc.json
# }

# resource "aws_iam_policy" "aws_lbc" {
#   policy = file("./iam/AWSLoadBalancerController.json")
#   name   = "AWSLoadBalancerController"
# }

# resource "aws_iam_role_policy_attachment" "aws_lbc" {
#   policy_arn = aws_iam_policy.aws_lbc.arn
#   role       = aws_iam_role.aws_lbc.name
# }



# resource "aws_eks_pod_identity_association" "aws_lbc" {
#   cluster_name    = module.eks.cluster_name
#   namespace       = "kube-system"
#   service_account = "aws-load-balancer-controller"
#   role_arn        = aws_iam_role.aws_lbc.arn
# }

# ###############################################################################
# # AWS Load Balancer Controller Helm
# ###############################################################################
# resource "helm_release" "aws_lbc" {
#   name = "aws-load-balancer-controller"

#   repository = "https://aws.github.io/eks-charts"
#   chart      = "aws-load-balancer-controller"
#   namespace  = "kube-system"
#   version    = "1.11.0"

#   values = [<<EOF
#     clusterName: ${module.eks.cluster_name}
#     serviceAccount:
#       name: aws-load-balancer-controller
#     replicaCount: 1
#     tolerations:
#       - key: system-critical
#         effect: NoSchedule
#     resources:
#       requests:
#         cpu: "100m"
#         memory: "128Mi"
#       limits:
#         cpu: "500m" 
#         memory: "256Mi"
#   EOF
#   ]

#   depends_on = [
#     module.eks,
#     aws_eks_pod_identity_association.aws_lbc,
#     aws_iam_policy.aws_lbc,
#     aws_iam_role_policy_attachment.aws_lbc,
#     aws_iam_role.aws_lbc,
#     data.aws_iam_policy_document.aws_lbc,
#     module.karpenter,
#     helm_release.karpenter,
#     helm_release.karpenter-manifests
#   ]

# }


