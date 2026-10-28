variable "my_ip" {
  description = "Your public IP as CIDR, e.g. 203.0.113.10/32"
  type        = string
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
}

resource "aws_key_pair" "lab" {
  key_name   = "test_aws_key"
  public_key = file("~/.ssh/id_ed25519.pub")
}

resource "aws_security_group" "lab" {
  name        = "ansible-lab"
  description = "SSH from my IP, all traffic inside the group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "controller" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.lab.key_name
  vpc_security_group_ids = [aws_security_group.lab.id]

  user_data = <<-EOF
    #!/bin/bash
    dnf install -y ansible-core vim tmux
  EOF

  tags = { Name = "ansible-controller" }
}

resource "aws_instance" "managed" {
  count                  = 2
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.lab.key_name
  vpc_security_group_ids = [aws_security_group.lab.id]

  tags = { Name = "ansible-node${count.index + 1}" }
}

output "controller_ip" {
  value = aws_instance.controller.public_ip
}

output "managed_private_ips" {
  value = aws_instance.managed[*].private_ip
}
