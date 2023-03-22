output "bastion_ssh_command" {
  value = [
    "ssh -A -o StrictHostKeyChecking=no ec2-user@${aws_instance.msk_bastion_instance.public_ip}"
  ]
}