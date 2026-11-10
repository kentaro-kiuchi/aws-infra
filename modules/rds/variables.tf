variable "env" {
  type        = string
  description = "Environment name."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for the database security group."
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for the DB subnet group."
}

variable "availability_zone" {
  type        = string
  description = "Availability Zone for the Single-AZ database instance."
}

variable "allowed_client_cidr" {
  type        = string
  description = "CIDR block allowed to connect to PostgreSQL."
}

variable "engine_version" {
  type        = string
  description = "PostgreSQL engine version."
}

variable "instance_class" {
  type        = string
  description = "RDS DB instance class."
}

variable "allocated_storage" {
  type        = number
  description = "Allocated database storage in GiB."
}

variable "storage_type" {
  type        = string
  description = "RDS storage type."
}

variable "master_username" {
  type        = string
  description = "Master user name for the database."
}

variable "manage_master_password" {
  type        = bool
  description = "Whether RDS manages the master password in Secrets Manager."
  default     = true
}
