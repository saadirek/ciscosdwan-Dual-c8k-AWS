terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = var.deployment_region
}

resource "aws_vpc" "cisco_sdwan_transit_vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "cisco_sdwan_transit_vpc"
  }
}

resource "aws_internet_gateway" "sdwan_igw" {
  vpc_id = aws_vpc.cisco_sdwan_transit_vpc.id

  tags = {
    Name = "sdwan_igw"
  }
}

resource "aws_default_route_table" "default_route_table" {
  default_route_table_id = aws_vpc.cisco_sdwan_transit_vpc.default_route_table_id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sdwan_igw.id
  }
}




resource "aws_subnet" "wan_subnet_1" {
  vpc_id     = aws_vpc.cisco_sdwan_transit_vpc.id
  cidr_block = var.wan_subnet_1
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "wan_subnet_1"
  }
}

resource "aws_subnet" "wan_subnet_2" {
  vpc_id     = aws_vpc.cisco_sdwan_transit_vpc.id
  cidr_block = var.wan_subnet_2
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "wan_subnet_1"
  }
}
resource "aws_subnet" "lan_subnet_1" {
  vpc_id     = aws_vpc.cisco_sdwan_transit_vpc.id
  cidr_block = var.lan_subnet_1
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "lan_subnet_1"
  }
}

resource "aws_subnet" "lan_subnet_2" {
  vpc_id     = aws_vpc.cisco_sdwan_transit_vpc.id
  cidr_block = var.lan_subnet_2
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "lan_subnet_2"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_instance" "c8kv-1" {
  ami           = var.c8kv_ami
  instance_type = "c5n.large"
  user_data = file("./config_1.cfg")  
  network_interface {
    network_interface_id = aws_network_interface.wan_c8k_1.id
    device_index         = 0
  }
  tags = {
    Name = "c8000v_SDWAN_1"
  }
}

resource "aws_instance" "c8kv-2" {
  ami           = var.c8kv_ami
  instance_type = "c5n.large"
  user_data = file("./config_2.cfg")  
  network_interface {
    network_interface_id = aws_network_interface.wan_c8k_2.id
    device_index         = 0
  }  
  tags = {
    Name = "c8000v_SDWAN_2"
  }
}

resource "aws_eip" "c8k_public_ip_1" {
  instance = aws_instance.c8kv-1.id
  vpc      = true
}

resource "aws_eip" "c8k_public_ip_2" {
  instance = aws_instance.c8kv-2.id
  vpc      = true
}

resource "aws_security_group" "sg_sdwan_wan" {
  name        = "sg_sdwan_wan"
  description = "Allow SDWAN inbound traffic"
  vpc_id      = aws_vpc.cisco_sdwan_transit_vpc.id

  ingress {
    description      = "SSH"
    from_port        = 0
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "sg_sdwan_wan"
  }
}

resource "aws_network_interface" "lan_c8k_1" {
  subnet_id       = aws_subnet.lan_subnet_1.id
  attachment {
    instance     = aws_instance.c8kv-1.id
    device_index = 1
  }
}


resource "aws_network_interface" "lan_c8k_2" {
  subnet_id       = aws_subnet.lan_subnet_2.id

  attachment {
    instance     = aws_instance.c8kv-2.id
    device_index = 1
  }
}
resource "aws_network_interface" "wan_c8k_1" {
  subnet_id       = aws_subnet.wan_subnet_1.id
  security_groups = [aws_security_group.sg_sdwan_wan.id]
}
resource "aws_network_interface" "wan_c8k_2" {
  subnet_id       = aws_subnet.wan_subnet_2.id
  security_groups = [aws_security_group.sg_sdwan_wan.id]
  
}