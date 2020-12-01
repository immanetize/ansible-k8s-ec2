resource "aws_iam_role" "etcd_node_role" {
  name = "etcd_node_role"
  assume_role_policy = <<EOF
{   
   "Version": "2012-10-17",
   "Statement": [
     {
       "Effect": "Allow",
       "Principal": {
         "Service": "ec2.amazonaws.com"
       },
       "Action": "sts:AssumeRole"
     }
   ]
}
    EOF
  tags = {
    "name": "etcd_node_role"
    "randomuser.org/usage": "etcd_nodes"
  }
}

resource "aws_iam_policy" "etcd_node_bootstrap_policy" {
  name = "etcd_node_bootstrap_policy"
  description = "enables self-discovery of peer nodes"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeTags",
                "autoscaling:DescribeAutoScalingInstances",
                "ec2:DescribeInstances",
                "ec2:DescribeTags"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
          "Action": [
            "elasticloadbalancing:DescribeLoadBalancers"
          ],
          "Resource": "*",
          "Effect": "Allow"
        },
        {
          "Action": [
						"s3:DeleteObject",
						"s3:GetObject",
						"s3:GetObjectAcl",
						"s3:GetObjectTagging",
						"s3:GetObjectTorrent",
						"s3:GetObjectVersion",
						"s3:GetObjectVersionAcl",
						"s3:GetObjectVersionTagging",
						"s3:ListBucket",
						"s3:PutObject",
						"s3:PutObjectAcl",
						"s3:PutObjectTagging",
						"s3:PutObjectVersionAcl",
						"s3:PutObjectVersionTagging"
					],
					"Effect": "Allow",
					"Resource": "arn:aws:s3:::cluster0-lockbox/*"
				},
        {
          "Action": ["s3:ListBucket"],
					"Effect": "Allow",
					"Resource": "arn:aws:s3:::cluster0-lockbox"
        }
    ]
}
  EOF
}

resource "aws_iam_role_policy_attachment" "etcd_policy_attach" {
  role = aws_iam_role.etcd_node_role.name
  policy_arn = aws_iam_policy.etcd_node_bootstrap_policy.arn
}

resource "aws_iam_instance_profile" "etcd_node_profile" {
  name = "etcd_node_profile"
  role = aws_iam_role.etcd_node_role.name
}
