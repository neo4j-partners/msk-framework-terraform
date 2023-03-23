output "bastion_ssh_command" {
  value = [
    "ssh -A -o StrictHostKeyChecking=no ec2-user@${aws_instance.msk_bastion_instance.public_ip}"
  ]
}

output "msk_test_ssh_command" {
  value = [
    "ssh -A -o StrictHostKeyChecking=no ec2-user@${aws_instance.msk_client_instance.private_ip}"
  ]
}

output "brokers" {
  value = data.aws_msk_cluster.the_msk_cluster.bootstrap_brokers_sasl_iam
}