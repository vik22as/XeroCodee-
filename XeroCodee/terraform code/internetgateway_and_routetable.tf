resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "igw-${var.project}"
  }
}

resource "aws_route_table" "rtb-pubsub" {
  vpc_id = aws_vpc.vpc.id

  route{
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    "Name" = "rtb-${var.project}"
  }
}

resource "aws_route_table_association" "rtb-assn-1" {
   route_table_id = aws_route_table.rtb-pubsub.id
   subnet_id = aws_subnet.pubsub-1.id
}

resource "aws_route_table_association" "rtb-assn-2" {
   route_table_id = aws_route_table.rtb-pubsub.id
   subnet_id = aws_subnet.pubsub-2.id
}

