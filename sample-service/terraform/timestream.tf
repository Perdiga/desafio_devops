##### Timestream #####
resource "aws_timestreamwrite_database" "db" {
  database_name = local.timestream_database_name

  tags = local.tags
}

resource "aws_timestreamwrite_table" "ec2_usage_table" {
  database_name = aws_timestreamwrite_database.db.database_name
  table_name    = "ec2_usage_table"

  magnetic_store_write_properties {
    enable_magnetic_store_writes = true
  }

  retention_properties {
    magnetic_store_retention_period_in_days = 2
    memory_store_retention_period_in_hours  = 8
  }

  tags = local.tags
}

##### IAM Grafana -> Timestream #####
/*
resource "aws_iam_role_policy_attachment" "Challange-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonTimestreamFullAccess"
  role       = module.eks.cluster_iam_role_name
}

resource "aws_iam_role" "cluster-iam" {
  name = local.cluster_name

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::441346804012:role/private-nodes-eks-node-group-20240304032802167200000001"
      }
    }]
    Version = "2012-10-17"
  })
}
*/

