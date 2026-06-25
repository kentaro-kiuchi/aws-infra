resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = var.github_oidc_thumbprints
}

resource "aws_iam_role" "github_actions_bootstrap" {
  name = var.github_actions_bootstrap_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = var.github_bootstrap_oidc_subjects
          }
        }
      }
    ]
  })
}

data "aws_iam_policy_document" "github_actions_bootstrap" {
  statement {
    sid    = "ReadWriteBootstrapTerraformState"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = [for key in var.bootstrap_tfstate_object_keys : "${var.tfstate_bucket_arn}/${key}"]
  }

  statement {
    sid    = "ReadWriteBootstrapTerraformLockfile"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]

    resources = [for key in var.bootstrap_tfstate_object_keys : "${var.tfstate_bucket_arn}/${key}.tflock"]
  }

  statement {
    sid    = "ListBootstrapTerraformStateBucket"
    effect = "Allow"

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      var.tfstate_bucket_arn,
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:prefix"
      values   = concat(var.bootstrap_tfstate_object_keys, [for key in var.bootstrap_tfstate_object_keys : "${key}.tflock"])
    }
  }

  statement {
    sid    = "ManageTerraformStateBucket"
    effect = "Allow"

    actions = [
      "s3:CreateBucket",
      "s3:GetAccelerateConfiguration",
      "s3:GetBucketAcl",
      "s3:GetBucketCORS",
      "s3:GetBucketLocation",
      "s3:GetBucketLogging",
      "s3:GetBucketObjectLockConfiguration",
      "s3:GetBucketOwnershipControls",
      "s3:GetBucketPolicy",
      "s3:GetBucketPublicAccessBlock",
      "s3:GetBucketRequestPayment",
      "s3:GetBucketTagging",
      "s3:GetBucketVersioning",
      "s3:GetBucketWebsite",
      "s3:GetEncryptionConfiguration",
      "s3:GetLifecycleConfiguration",
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
      "s3:PutBucketPolicy",
      "s3:PutBucketPublicAccessBlock",
      "s3:PutBucketTagging",
      "s3:PutBucketVersioning",
      "s3:PutBucketOwnershipControls",
      "s3:PutEncryptionConfiguration",
      "s3:PutLifecycleConfiguration",
    ]

    resources = [
      var.tfstate_bucket_arn,
    ]
  }

  statement {
    sid    = "ListOidcProviders"
    effect = "Allow"

    actions = [
      "iam:ListOpenIDConnectProviders",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ManageGithubOidcProvider"
    effect = "Allow"

    actions = [
      "iam:AddClientIDToOpenIDConnectProvider",
      "iam:CreateOpenIDConnectProvider",
      "iam:DeleteOpenIDConnectProvider",
      "iam:GetOpenIDConnectProvider",
      "iam:ListOpenIDConnectProviderTags",
      "iam:RemoveClientIDFromOpenIDConnectProvider",
      "iam:TagOpenIDConnectProvider",
      "iam:UntagOpenIDConnectProvider",
      "iam:UpdateOpenIDConnectProviderThumbprint",
    ]

    resources = [
      aws_iam_openid_connect_provider.github.arn,
    ]
  }

  statement {
    sid    = "ManageGithubActionsRoles"
    effect = "Allow"

    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:DeleteRolePolicy",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:ListRolePolicies",
      "iam:ListRoleTags",
      "iam:PutRolePolicy",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:UpdateAssumeRolePolicy",
      "iam:UpdateRole",
    ]

    resources = [
      aws_iam_role.github_actions_bootstrap.arn,
      aws_iam_role.github_actions_env.arn,
    ]
  }

  statement {
    sid    = "ReadCallerIdentity"
    effect = "Allow"

    actions = [
      "sts:GetCallerIdentity",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "github_actions_bootstrap" {
  name   = "${var.github_actions_bootstrap_role_name}-bootstrap"
  role   = aws_iam_role.github_actions_bootstrap.id
  policy = data.aws_iam_policy_document.github_actions_bootstrap.json
}

resource "aws_iam_role" "github_actions_env" {
  name = var.github_actions_env_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = var.github_env_oidc_subjects
          }
        }
      }
    ]
  })
}

data "aws_iam_policy_document" "github_actions_env_state_backend" {
  statement {
    sid    = "ReadWriteTerraformState"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = [for key in var.tfstate_object_keys : "${var.tfstate_bucket_arn}/${key}"]
  }

  statement {
    sid    = "ReadWriteTerraformLockfile"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]

    resources = [for key in var.tfstate_object_keys : "${var.tfstate_bucket_arn}/${key}.tflock"]
  }

  statement {
    sid    = "ListTerraformStateBucket"
    effect = "Allow"

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      var.tfstate_bucket_arn,
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:prefix"
      values   = concat(var.tfstate_object_keys, [for key in var.tfstate_object_keys : "${key}.tflock"])
    }
  }
}

resource "aws_iam_role_policy" "github_actions_env_state_backend" {
  name   = "${var.github_actions_env_role_name}-state-backend"
  role   = aws_iam_role.github_actions_env.id
  policy = data.aws_iam_policy_document.github_actions_env_state_backend.json
}

data "aws_iam_policy_document" "github_actions_env_managed_resources" {
  statement {
    sid    = "ManageVpc"
    effect = "Allow"

    actions = [
      "ec2:CreateTags",
      "ec2:CreateVpc",
      "ec2:DeleteTags",
      "ec2:DeleteVpc",
      "ec2:DescribeVpcAttribute",
      "ec2:DescribeVpcs",
      "ec2:ModifyVpcAttribute",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ReadCallerIdentity"
    effect = "Allow"

    actions = [
      "sts:GetCallerIdentity",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "github_actions_env_managed_resources" {
  name   = "${var.github_actions_env_role_name}-managed-resources"
  role   = aws_iam_role.github_actions_env.id
  policy = data.aws_iam_policy_document.github_actions_env_managed_resources.json
}
