variable "name" {
  default = "codedeploy-demo"
}

variable "region" {
  default = "ap-northeast-1"
}

variable "vpc_cidr" {
  default = "172.16.0.0/16"
}

variable "azs" {
  default = "ap-northeast-1a,ap-northeast-1c"
}

variable "public_subnets" {
  default = "172.16.0.0/24,172.16.1.0/24"
}

variable "fleet_type" {
  default = "t2.nano"
}

variable "fleet_ami_id" {
  default = "ami-383c1956"
}

variable "desired_capacity" {
  default = 1
}

variable "max_size" {
  default = 1
}

variable "min_size" {
  default = 1
}
