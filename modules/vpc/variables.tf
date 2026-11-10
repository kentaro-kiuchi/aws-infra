variable "env" {
  type        = string
  description = "Environment name."
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC."
}

variable "subnets" {
  type = map(object({
    availability_zone = string
    cidr_block        = string
    tier              = string
  }))
  description = "Subnet definitions keyed by subnet name."
  default     = {}
}
