resource "aws_iam_role" "k8s_worker_role" {
  name = "k8s_worker_role"
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
    "Name": "k8s_worker_role"
    "randomuser.org/usage": "worker-nodes"
  }
}
resource "aws_iam_policy" "kube_worker_policy" {
  name = "kube_worker_policy"
  description = "enables k8s AWS cloud provider"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeTags",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribeAutoScalingInstances",
                "ec2:DescribeLaunchTemplateVersions",
                "ec2:DescribeInstances",
                "ec2:DescribeTags"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
          "Action": [
            "elasticloadbalancing:DescribeLoadBalancers",
            "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
            "elasticloadbalancing:RegisterInstancesWithLoadBalancer"
          ],
          "Resource": "*",
          "Effect": "Allow"
        },
        {
          "Action": [
						"s3:GetObject",
						"s3:GetObjectAcl",
						"s3:GetObjectTagging",
						"s3:GetObjectTorrent",
						"s3:GetObjectVersion",
						"s3:GetObjectVersionAcl",
						"s3:GetObjectVersionTagging",
						"s3:ListBucket"
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

resource "aws_iam_role_policy_attachment" "worker_policy_attach" {
  role = aws_iam_role.k8s_worker_role.name
  policy_arn = aws_iam_policy.kube_worker_policy.arn
}

resource "aws_iam_instance_profile" "worker_node_profile" {
  name = "worker_node_profile"
  role = aws_iam_role.k8s_worker_role.name
}

