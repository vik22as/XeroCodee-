resource "aws_lb_target_group" "tg" {
  port     = 80
  protocol = "HTTP"
  target_type = "instance"
  vpc_id   = aws_vpc.vpc.id
  
  tags = {
    "Name" = "tg-${var.project}"
  }
}


resource "aws_lb" "lb" {
  internal = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id]                        # not done
  subnets            = [aws_subnet.pubsub-1.id,aws_subnet.pubsub-2.id]           #[for subnet in aws_subnet.public : subnet.id]

  enable_deletion_protection = false

  tags = {
      "Name":"lb-${var.project}"
  }
}

resource "aws_lb_listener" "lbl" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }

  tags = {
    "Name" = "lb-listner-${var.project}"
  }
}

output "lb_dns" {
  value = aws_lb.lb.dns_name
}

