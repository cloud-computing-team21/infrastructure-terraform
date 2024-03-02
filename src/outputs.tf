output "bastion_host_public_ips" {
  value       = module.bastion_hosts.*.public_ip
  description = "The public IP addresses of the bastion hosts"
}

output "rds_endpoint" {
  value       = element(module.rds.*.endpoint, 0)
  description = "The endpoint of the RDS instance."
}

output "rds_aurora_endpoint" {
  value       = element(module.rds_aurora.*.endpoint, 0)
  description = "The endpoint of the RDS instance."
}
