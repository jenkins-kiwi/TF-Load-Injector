# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_instance" "server" {
  count                  = "${var.max_instance}"
  ami                    = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type          = "${var.instance_type}"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${var.sg_name}"]

  #volume_size     = 5

  subnet_id                   = "subnet-a60ef5fc"
  associate_public_ip_address = true

  #source_dest_check           = false

  root_block_device = {
    #volume_type           = "gp2"
    #volume_size           = "15"
    delete_on_termination = true
  }
  tags {
    Name        = "${var.project}_Server_${count.index}"
    Owner       = "${var.owner}"
    CreatedBy   = "${var.creator}"
    RequestedBy = "${var.requester}"
    Environment = "${var.project}"
  }
}
