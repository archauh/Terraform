variable "my_cidr" {
  description = "VPC"
  default = "10.0.0.0/16"
}

variable "ami_id" {
  description = "AMI ID for EC2 instance"
  type        = string
  default     = "ami-0e35ddab05955cf57"
}

variable "instancetype" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}
