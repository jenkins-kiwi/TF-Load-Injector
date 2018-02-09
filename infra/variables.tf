variable "project" {
  default = ""
}

#
# variable "private_key" {
#   default = ""
# }

variable "key_name" {
  description = "Desired name of AWS key pair"
  default     = "kiwi-devops"
}

#variable "public_key_file" {}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-east-1"
}

variable "instance_type" {
  default = "t2.medium"
}

# Ubuntu Precise 16.04 LTS (x64)
variable "aws_amis" {
  default = {
    us-east-1 = "ami-b0fdb0ca"

    # us-east-2  = "ami-fcc19b99"
    # us-west-1  = "ami-16efb076"
    # us-west-2  = "ami-a58d0dc5"
    # ap-south-1 = "ami-5d055232"
  }
}

variable "max_instance" {
  default = "1"
}

variable "sg_name" {
  default = "sg-2ffc8d51"
}

variable "requester" {}
variable "creator" {}
variable "owner" {}
