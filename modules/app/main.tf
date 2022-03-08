resource "aws_instance" "bastion" {
  ami                         = "ami-08b6f2a5c291246a0"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.env_security_group]
  subnet_id                   = var.public_subnet_id_a
  user_data                   = file("${path.module}/user_data.sh")
  iam_instance_profile        = "s3-full"
  key_name                    = "prod-key"

  tags = {
    Name = "Bastion"
  }

  depends_on = [var.aws_db_php]
}

resource "aws_key_pair" "prod" {
  key_name   = "prod-key"
  public_key = file("${path.module}/prod.rsa")
}


resource "aws_ami_from_instance" "php_app" {
  name               = "php-app-image"
  source_instance_id = aws_instance.bastion.id
  depends_on         = [aws_instance.bastion]
}

resource "aws_lb" "php_app" {
  name               = "php-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.env_security_group]
  subnets            = [var.public_subnet_id_a, var.public_subnet_id_b]

  enable_deletion_protection = false

  tags = {
    Name = "PHP_LB"
  }

  depends_on = [aws_instance.bastion]
}

resource "aws_launch_configuration" "php_app" {
  name                 = "php_app"
  image_id             = aws_ami_from_instance.php_app.id
  instance_type        = "t2.micro"
  security_groups      = [var.env_security_group]
  iam_instance_profile = "s3-full"
  key_name             = "prod-key"

  depends_on = [aws_instance.bastion]
}

resource "aws_autoscaling_group" "php_app" {
  name                      = "php_app"
  max_size                  = 3
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = 2
  force_delete              = true
  #placement_group           = aws_placement_group.test.id
  launch_configuration = aws_launch_configuration.php_app.name
  vpc_zone_identifier  = [var.private_subnet_id_a, var.private_subnet_id_b]
  depends_on           = [aws_instance.bastion]
  lifecycle {
    ignore_changes = ["target_group_arns"]
  }

}

resource "aws_lb_target_group" "php_app" {
  name       = "php-app-lb-tg"
  port       = 80
  protocol   = "HTTP"
  vpc_id     = var.vpc_id
  depends_on = [aws_instance.bastion]
}
resource "aws_autoscaling_attachment" "php_app" {
  autoscaling_group_name = aws_autoscaling_group.php_app.id
  lb_target_group_arn    = aws_lb_target_group.php_app.arn
  depends_on             = [aws_instance.bastion]
}

resource "aws_lb_listener" "php_app_tg" {
  load_balancer_arn = aws_lb.php_app.arn
  port              = "443"
  protocol          = "HTTPS"
  depends_on        = [aws_instance.bastion]
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:us-east-2:990032074338:certificate/332fe32a-1a0a-4b8e-ad08-54a6ba710712"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.php_app.arn
  }
}

resource "aws_lb_listener" "php_app_https_to_http" {
  load_balancer_arn = aws_lb.php_app.arn
  port              = "80"
  protocol          = "HTTP"
  depends_on        = [aws_instance.bastion]
  #  ssl_policy        = "ELBSecurityPolicy-2016-08"
  #  certificate_arn   = "arn:aws:acm:us-east-2:990032074338:certificate/332fe32a-1a0a-4b8e-ad08-54a6ba710712"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

data "aws_route53_zone" "selected" {
  name         = "oyamkovyi.link"
  private_zone = false
}

resource "aws_route53_record" "php_app" {
  zone_id = data.aws_route53_zone.selected.id
  name    = "app"
  type    = "A"

  alias {
    name                   = aws_lb.php_app.dns_name
    zone_id                = aws_lb.php_app.zone_id
    evaluate_target_health = true
  }
  depends_on = [aws_instance.bastion]
}
