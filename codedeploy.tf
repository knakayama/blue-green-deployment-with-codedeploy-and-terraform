resource "aws_s3_bucket" "codedeploy" {
  bucket        = "${md5(aws_codedeploy_app.codedeploy.id)}"
  acl           = "private"
  force_destroy = true
}

resource "aws_iam_role" "codedeploy" {
  name               = "${var.name}-codedeploy-role"
  assume_role_policy = "${file("assume_role_policy_codedeploy.json")}"
}

resource "aws_iam_policy_attachment" "codedeploy" {
  name       = "AWSCodeDeployRole"
  roles      = ["${aws_iam_role.codedeploy.name}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

resource "aws_codedeploy_app" "codedeploy" {
  name = "codedeploy-demo"
}
