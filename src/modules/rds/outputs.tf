output "endpoint" {
  value       = aws_db_instance.master.endpoint
  description = "The endpoint of the RDS instance."
}
