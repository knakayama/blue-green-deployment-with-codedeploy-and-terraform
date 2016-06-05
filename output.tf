output "s3_bucket" {
  value = "${aws_s3_bucket.codedeploy.bucket}"
}

output "elb_dns_name" {
  value = "${aws_elb.elb.dns_name}"
}
