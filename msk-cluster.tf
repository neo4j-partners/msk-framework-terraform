resource "aws_msk_cluster" "msk_cluster" {
  cluster_name           = "${var.env_prefix}-msk-cluster"
  kafka_version          = "2.8.1"
  number_of_broker_nodes = 3

  client_authentication {
    sasl {
      iam = true
    }
  }

  broker_node_group_info {
    instance_type = "kafka.m5.large"
    client_subnets = [
      aws_subnet.msk_private_subnet[0].id,
      aws_subnet.msk_private_subnet[1].id,
      aws_subnet.msk_private_subnet[2].id,
    ]
    storage_info {
      ebs_storage_info {
        volume_size = 1000
      }
    }
    security_groups = [aws_security_group.msk_private_sg.id]
  }

 tags = {
    "Name"      = "${var.env_prefix}-msk-cluster"
    "Terraform" = true
  }
}
