resource "aws_elb" "elb" {
  name                        = "${var.name}-elb"
  subnets                     = ["${aws_subnet.public.*.id}"]
  security_groups             = ["${aws_security_group.elb.id}"]
  cross_zone_load_balancing   = true
  connection_draining         = true
  connection_draining_timeout = 300
  idle_timeout                = 60

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = 80
    instance_protocol = "http"
  }

  listener {
    lb_port           = 1022
    lb_protocol       = "tcp"
    instance_port     = 22
    instance_protocol = "tcp"
  }

  health_check {
    healthy_threshold   = 10
    unhealthy_threshold = 2
    timeout             = 5
    target              = "HTTP:80/index.html"
    interval            = 30
  }

  tags {
    Name = "${var.name}-elb"
  }
}

resource "aws_key_pair" "site_key" {
  key_name   = "${var.name}"
  public_key = "${file("keys/site_key.pub")}"
}

resource "aws_iam_role" "fleet" {
  name               = "${var.name}-fleet-role"
  assume_role_policy = "${file("assume_role_policy_fleet.json")}"
}

resource "aws_iam_instance_profile" "fleet" {
  name  = "${var.name}-fleet-role"
  roles = ["${aws_iam_role.fleet.name}"]
}

resource "aws_iam_policy_attachment" "fleet" {
  name       = "ReadOnlyAccess"
  roles      = ["${aws_iam_role.fleet.name}"]
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_launch_configuration" "fleet" {
  name_prefix                 = "${var.name}-fleet-"
  image_id                    = "${var.fleet_ami_id}"
  instance_type               = "${var.fleet_type}"
  key_name                    = "${aws_key_pair.site_key.key_name}"
  security_groups             = ["${aws_security_group.fleet.id}"]
  iam_instance_profile        = "${aws_iam_instance_profile.fleet.id}"
  user_data                   = "${file("cloud_config.yml")}"
  associate_public_ip_address = true
  enable_monitoring           = true

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
  }

  lifecycle {
    create_before_destroy = true
  }
}

module "blue" {
  source = "./modules/asg/blue"

  name                      = "${var.name}-blue"
  launch_configuration_name = "${aws_launch_configuration.fleet.name}"
  public_subnet_id          = "${aws_subnet.public.0.id}"
  desired_capacity          = "${var.desired_capacity}"
  max_size                  = "${var.max_size}"
  min_size                  = "${var.min_size}"
  load_balancer_id          = "${aws_elb.elb.id}"
  app_name                  = "${aws_codedeploy_app.codedeploy.name}"
  service_role_arn          = "${aws_iam_role.codedeploy.arn}"
}

module "green" {
  source = "./modules/asg/green"

  name                      = "${var.name}-green"
  launch_configuration_name = "${aws_launch_configuration.fleet.name}"
  public_subnet_id          = "${aws_subnet.public.0.id}"
  desired_capacity          = "${var.desired_capacity}"
  max_size                  = "${var.max_size}"
  min_size                  = "${var.min_size}"
  load_balancer_id          = "${aws_elb.elb.id}"
  app_name                  = "${aws_codedeploy_app.codedeploy.name}"
  service_role_arn          = "${aws_iam_role.codedeploy.arn}"
}
