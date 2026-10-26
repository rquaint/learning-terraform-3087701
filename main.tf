data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

# Ansible Controller
resource "aws_instance" "controller" {
  ami           = data.aws_ami.app_ami.id
  instance_type = "t3.micro"
  key_name      = "test_aws_key"  # your .pem key name in AWS

  user_data = <<-EOF
    #!/bin/bash
    # Enable root SSH
    sed -i 's/PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config
    sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config

    # SSH keepalive
    echo "ClientAliveInterval 60" >> /etc/ssh/sshd_config
    echo "ClientAliveCountMax 10" >> /etc/ssh/sshd_config

    # Enable password auth
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

    # Install packages
    dnf install -y ansible python3 vim tmux bash-completion

    # Install Terraform
    yum install -y yum-utils
    yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
    yum install -y terraform

    # Create ansible user
    useradd ansible
    echo "ansible:procoreplus" | chpasswd
    usermod -aG wheel ansible
    echo "ansible ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ansible

    # Bash completion
    echo "source /etc/profile.d/bash_completion.sh" >> /root/.bashrc

    systemctl restart sshd
  EOF

  tags = {
    Name = "ansible-controller"
  }
}

# Managed Node 1
resource "aws_instance" "node1" {
  ami           = data.aws_ami.app_ami.id
  instance_type = "t3.micro"
  key_name      = "test_aws_key"

  user_data = <<-EOF
    #!/bin/bash
    sed -i 's/PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config
    sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config
    echo "ClientAliveInterval 60" >> /etc/ssh/sshd_config
    echo "ClientAliveCountMax 10" >> /etc/ssh/sshd_config
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
    dnf install -y python3 vim bash-completion
    useradd ansible
    echo "ansible:procoreplus" | chpasswd
    usermod -aG wheel ansible
    echo "ansible ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ansible
    systemctl restart sshd
  EOF

  tags = {
    Name = "ansible-node1"
  }
}

# Managed Node 2
resource "aws_instance" "node2" {
  ami           = data.aws_ami.app_ami.id
  instance_type = "t3.micro"
  key_name      = "test_aws_key"

  user_data = <<-EOF
    #!/bin/bash
    sed -i 's/PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config
    sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config
    echo "ClientAliveInterval 60" >> /etc/ssh/sshd_config
    echo "ClientAliveCountMax 10" >> /etc/ssh/sshd_config
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
    dnf install -y python3 vim bash-completion
    useradd ansible
    echo "ansible:procoreplus" | chpasswd
    usermod -aG wheel ansible
    echo "ansible ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ansible
    systemctl restart sshd
  EOF

  tags = {
    Name = "ansible-node2"
  }
}
