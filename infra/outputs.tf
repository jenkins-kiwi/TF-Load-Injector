output "PUBLIC_IPS" {
  value = "${aws_instance.server.*.public_ip}"
}
