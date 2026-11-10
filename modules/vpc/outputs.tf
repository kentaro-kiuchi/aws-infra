output "vpc_id" {
  value       = aws_vpc.main.id
  description = "VPC ID."
}

output "private_subnet_ids" {
  value       = [for name, subnet in aws_subnet.this : subnet.id if var.subnets[name].tier == "private"]
  description = "IDs of private subnets."
}

output "public_subnet_ids" {
  value       = [for name, subnet in aws_subnet.this : subnet.id if var.subnets[name].tier == "public"]
  description = "IDs of public subnets."
}
