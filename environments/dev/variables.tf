# Infrastuctre Variable defination
variable "region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "account" {
  description = "Account name"
  type        = string
}
variable "account_id" {
  description = "Account name"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "Must be a valid IPv4 CIDR block address."
  }
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)

  validation {
    condition     = alltrue([for cidr in var.private_subnets : can(cidrhost(cidr, 0))])
    error_message = "All private subnet CIDR blocks must be valid IPv4 CIDR block addresses."
  }
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)

  validation {
    condition     = alltrue([for cidr in var.public_subnets : can(cidrhost(cidr, 0))])
    error_message = "All public subnet CIDR blocks must be valid IPv4 CIDR block addresses."
  }
}

variable "bastion_ami" {
}

variable "instance_type_bastion" {
}

variable "instance_type" {
  description = "Set of instance types associated with the EKS Node Group. Defaults to `[\"t3.small\"]`"
  type        = list(string)
}
variable "key_name" {
}

variable "eks_version" {
}

variable "desired_size" {
}


variable "max_size" {
}

variable "min_size" {
}

variable "disk_size" {
}
