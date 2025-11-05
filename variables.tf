variable "prefix" {
  type    = string
  default = ""
}

variable "eks_environment" {
  type    = string
  default = "development"
}

variable "eks_region" {
  type    = string
  default = ""
}

variable "eks_profile" {
  type    = string
  default = ""
}

variable "eks_stack_name" {
  type    = string
  default = ""
}

variable "eks_cluster_name" {
  type    = string
  default = ""
}

variable "eks_vpc_cidr" {
  type    = string
  default = ""
}

variable "eks_public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["192.168.64.0/19", "192.168.0.0/19", "192.168.32.0/19"]
}

variable "eks_private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["192.168.160.0/19", "192.168.96.0/19", "192.168.128.0/19"]
}

variable "node_group_desired_capacity" {
  type    = number
  default = 2
}
variable "node_group_min_size" {
  type    = number
  default = 1
}

variable "node_group_max_size" {
  type    = number
  default = 3
}

variable "node_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "node_capacity_type" {
  type    = string
  default = "ON_DEMAND"
}
variable "enable_ssm" {
  type    = bool
  default = true
}
variable "eks_version" {
  type    = string
  default = "1.33"
}

variable "node_group_name" {
  description = "Optional explicit node group name. If empty, uses prefix-managed-nodes."
  type        = string
  default     = ""
}
