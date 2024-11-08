output "alb-dns" {
  value       = aws_lb.carlosgb-ALB.dns_name
  description = "dns del ALB"
}


