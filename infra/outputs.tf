output "address" {
  value = "${aws_instance.server.*.public_ip}"
}
