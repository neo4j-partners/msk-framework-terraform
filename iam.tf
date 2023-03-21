data "aws_caller_identity" "msk_current" {}

data "aws_iam_policy_document" "msk_connect_policy_doc" {
  statement {
    effect = "Allow"
    actions = [
      "kafka-cluster:Connect",
      "kafka-cluster:AlterCluster",
      "kafka-cluster:DescribeCluster"
    ]

    resources = [ "arn:aws:kafka:${var.target_region}:${data.aws_caller_identity.msk_current.account_id}:cluster/*/*" ]
  }

  statement {
    effect = "Allow"
    actions = [
      "kafka-cluster:DescribeTopic",
      "kafka-cluster:CreateTopic",
      "kafka-cluster:WriteData",
      "kafka-cluster:ReadData"
    ]

    resources = [ "arn:aws:kafka:${var.target_region}:${data.aws_caller_identity.msk_current.account_id}:topic/*/*/*" ]
  }

  statement {
    effect = "Allow"
    actions = [
      "kafka-cluster:AlterGroup",
      "kafka-cluster:DescribeGroup"
    ]

    resources = [ "arn:aws:kafka:${var.target_region}:${data.aws_caller_identity.msk_current.account_id}:group/*/*/*" ]
  }
}

resource "aws_iam_instance_profile" "msk_instance_profile" {
  name = "${var.env_prefix}-profile"
  role = aws_iam_role.msk_role.name
}

resource "aws_iam_policy" "msk_connect_policy" {
  name        = "${var.env_prefix}_msk_connect_policy"
  description = "MSK Policy"
  policy      = data.aws_iam_policy_document.msk_connect_policy_doc.json

  tags = {
    "Name"      = "${var.env_prefix}-connect-policy"
    "Terraform" = true
  }
}

resource "aws_iam_role" "msk_role" {
  name = "${var.env_prefix}-role"
  assume_role_policy = local.assume_role_policy

  tags = {
    "Name"      = "${var.env_prefix}-msk-role"
    "Terraform" = true
  }
}

resource "aws_iam_role_policy_attachment" "msk_role_policy_attachment" {
  role       = aws_iam_role.msk_role.name
  policy_arn = aws_iam_policy.msk_connect_policy.arn
}