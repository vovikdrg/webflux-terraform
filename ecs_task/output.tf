output "dns" {
  description = "Cluster url."
  value = aws_alb.application_load_balancer.dns_name
}