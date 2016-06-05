variable "name" {}

variable "launch_configuration_name" {}

variable "public_subnet_id" {}

variable "desired_capacity" {}

variable "max_size" {}

variable "min_size" {}

variable "app_name" {}

variable "service_role_arn" {}

variable "load_balancer_id" {}

resource "aws_autoscaling_group" "green" {
  name                      = "${var.name}"
  launch_configuration      = "${var.launch_configuration_name}"
  vpc_zone_identifier       = ["${var.public_subnet_id}"]
  desired_capacity          = "${var.desired_capacity}"
  max_size                  = "${var.max_size}"
  min_size                  = "${var.min_size}"
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  #load_balancers            = ["${var.load_balancer_id}"]

  tag {
    key                 = "Name"
    value               = "Green"
    propagate_at_launch = true
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_codedeploy_deployment_group" "green" {
  app_name              = "${var.app_name}"
  deployment_group_name = "Green"
  service_role_arn      = "${var.service_role_arn}"
  autoscaling_groups    = ["${aws_autoscaling_group.green.id}"]
}
