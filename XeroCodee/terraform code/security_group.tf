resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.vpc.id
  ingress{
      from_port = "80"
      to_port = "80"
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress{
      from_port = "22"
      to_port = "22"
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress{
    from_port = "3306"
    to_port = "3306"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress{
    from_port = "8080"
    to_port = "8080"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress{
      from_port = "0"
      to_port = "0"
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      prefix_list_ids = []
  }

  tags = {
    "Name" = "sg-${var.project}"
  }
}

resource "aws_security_group" "sg-rds" {
  vpc_id = aws_vpc.vpc.id
  ingress{
    from_port = "3306"
    to_port = "3306"
    protocol = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress{
      from_port = "0"
      to_port = "0"
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      prefix_list_ids = []
  }

  tags = {
    "Name" = "sg-rds-${var.project}"
  }

}