data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    # Had to make this correction manually - Robert Quaintance 10/25/2026 to follow along with the linkedin tutorial.
    # Updated: Bitnami owner (979382823631) no longer publishes this AMI.
    # Replaced with Amazon Linux 2023 - official AWS image, always current.
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"] # was "979382823631" (Bitnami) - retired 2026
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.app_ami.id
  instance_type = "t3.micro"    # was t3.nano - free tier eligible

  tags = {
    Name = "HelloWorld"
  }
}
