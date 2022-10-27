variable "deployment_region" {
  type = string
}

variable "wan_subnet_1" {
    type = string
}
variable "lan_subnet_1" {
    type = string
}

variable "wan_subnet_2" {
    type = string
}
variable "lan_subnet_2" {
    type = string
}

variable "c8kv_ami" { 
    type = string 
    default = "ami-06ea5ea2ee0dbff12"  # 17.6.1a
}

variable "vpc_cidr" {
    type = string
    default = "10.0.0.0/8"
}
