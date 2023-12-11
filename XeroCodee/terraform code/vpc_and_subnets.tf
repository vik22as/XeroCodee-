# define variables
variable "project" {}
variable "vpc_cidr" {}
variable "pubsub1_cidr" {}
variable "pubsub1_az" {}
variable "pubsub2_cidr" {}
variable "pubsub2_az" {}
variable "privsub_cidr" {}
variable "privsub_az" {}



#creating vpc 
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    "Name" = "vpc-${var.project}"
  }
}

resource "aws_subnet" "pubsub-1" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.pubsub1_cidr
  availability_zone = var.pubsub1_az
  map_public_ip_on_launch = true

  tags = {
    "Name" = "pubsub1-${var.project}"
  }
}

resource "aws_subnet" "pubsub-2" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.pubsub2_cidr
  availability_zone = var.pubsub2_az
  map_public_ip_on_launch = true

  tags = {
    "Name" = "pubsub2-${var.project}"
  }
}

resource "aws_subnet" "privsub" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.privsub_cidr
  availability_zone = var.privsub_az
  #map_public_ip_on_launch = true
  
  tags = {
    "Name" = "privsub-${var.project}"
  }
}

