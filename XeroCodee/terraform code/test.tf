variable "rds_username" {}
variable "rds_password" {}
variable "rds_instance_name" {}
variable "inst_type" {}
variable "ami" {}

#elastic ip for NAT
resource "aws_eip" "eip" {
    vpc = true

    tags = {
      "Name" = "eip-${var.project}"
    }
}

#NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.eip.id
  subnet_id = aws_subnet.pubsub-1.id
  tags = {
    "Name" = "nat-${var.project}"
  }
}


#output
output "nat_gateway_ip" {
  value = aws_eip.eip.public_ip
}

#route table for private subnet with a route to NAT from instances
resource "aws_route_table" "rtb-nat" {
  vpc_id = aws_vpc.vpc.id
  route{
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = {
    "Name" = "rtb-privsub-${var.project}"
  }
}

#association btw rtb and privsubnet
resource "aws_route_table_association" "asn-sub-nat" {
  subnet_id = aws_subnet.privsub.id
  route_table_id = aws_route_table.rtb-nat.id
}

/*#s3-Bucket
resource "aws_s3_bucket" "s3-bucket1" {
  bucket = "primary-bucket-${var.project}"
}

#acl
resource "aws_s3_bucket_acl" "s3-acl-1" {
  bucket = aws_s3_bucket.s3-bucket1.id
  acl = "private"
}

resource "aws_s3_bucket" "s3-bucket2" {
  bucket = "secondary-bucket-${var.project}"
}

resource "aws_s3_bucket_acl" "s3-acl-2" {
  bucket = aws_s3_bucket.s3-bucket2.id
  acl = "private"
} */

#DB subnet group
resource "aws_db_subnet_group" "default" {
  name       = "db_group-${var.project}"
  subnet_ids = [ aws_subnet.privsub.id,aws_subnet.pubsub-1.id, aws_subnet.pubsub-2.id]

  tags = {
    Name = "db_group-${var.project}"
  }
}
#rds instance
resource "aws_db_instance" "db_instance" {
  allocated_storage = 20
  identifier = "rds-${var.project}"
  storage_type = "gp2"
  engine = "mysql"
  availability_zone = var.privsub_az
  db_subnet_group_name = aws_db_subnet_group.default.name
  engine_version = "8.0.28"
  instance_class = "db.t2.micro"
  db_name = var.rds_instance_name
  username = var.rds_username
  vpc_security_group_ids = [ aws_security_group.sg-rds.id ]
  password = var.rds_password
  publicly_accessible    = false
  skip_final_snapshot    = true
  tags = {
    Name = "rds-mysql-${var.project}"
  }
}

#ec2 instance in private subnet
resource "aws_instance" "ec2_privsubnet" {
  ami = var.ami
  instance_type = var.inst_type
  

  subnet_id = aws_subnet.privsub.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  availability_zone = var.privsub_az
  
  #associate_public_ip_address = true

  user_data = <<EOF
  #!/bin/bash
  sudo apt-get update
  sudo apt-get install python3
  sudo apt-get install python3-pip
  sudo pip install PyMySQL
  
  
  EOF

  key_name = "tf_key_pair" #generated from ec2 dashboard

  tags={
      "Name" = "ec2-priv-${var.project}"
  }
}



