resource "aws_security_group" "elb" {
  name        = "${var.name}-elb"
  vpc_id      = "${aws_vpc.vpc.id}"
  description = "${var.name}-elb"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1022
    to_port     = 1022
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.name}-elb"
  }
}

resource "aws_security_group" "fleet" {
  name        = "${var.name}-fleet"
  vpc_id      = "${aws_vpc.vpc.id}"
  description = "${var.name}-fleet"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    #security_groups = ["${aws_security_group.elb.id}"]
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.elb.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.name}-fleet"
  }
}
