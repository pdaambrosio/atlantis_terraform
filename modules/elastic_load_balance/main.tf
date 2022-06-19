resource "aws_lb" "lb-instances" {
  name               = "lb-${var.prefix}"
  internal           = var.lb_internal
  load_balancer_type = var.type_loadbalancer
  subnets            = [var.subnet_id]

  tags = {
    Name = "lb-${var.prefix}"
  }
}

resource "aws_lb_target_group" "tg-instances" {
  name       = "tg-${var.prefix}"
  port       = var.tg_port
  protocol   = var.tg_protocol
  vpc_id     = var.tg_vpc_id
  depends_on = [aws_lb.lb-instances]
}

resource "aws_lb_listener" "listener-intances" {
  load_balancer_arn = aws_lb.lb-instances.arn
  port              = var.listerner_port
  protocol          = var.listener_protocol

  default_action {
    type             = var.listerner_type
    target_group_arn = aws_lb_target_group.tg-instances.arn
  }

  depends_on = [aws_lb_target_group.tg-instances]
}

resource "aws_alb_target_group_attachment" "tg-instances-attachement" {
  count            = var.tg_number_instances
  target_group_arn = aws_lb_target_group.tg-instances.arn
  target_id        = var.tg_instances_id[count.index]
  port             = var.tg_instances_port
  depends_on       = [aws_lb_listener.listener-intances]
}
