output "instance_ids" {
  description = "IDs of created EC2 instances master & slave"
  value       = aws_instance.jenkins_instance[*].id
}

output "public_ips" {
  description = "Public IPs of created EC2 instances master & slave"
  value       = aws_instance.jenkins_instance[*].public_ip
}

output "public_ips_slave" {
  description = "Private IPs of created EC2 instances"
  value       = aws_instance.jenkins_instance_slave[*].private_ip
}

