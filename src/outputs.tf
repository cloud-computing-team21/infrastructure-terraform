output "bastion_host_public_ip" {
  value       = module.bastion_host_ec2.public_ip
  description = "The public IP address of the bastion host"
}

output "rds_endpoint" {
  value       = element(module.rds.*.endpoint, 0)
  description = "The endpoint of the RDS instance."
}
