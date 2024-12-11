resource "aws_security_group" "sg_1" {
  name = "default"

  ingress {
    description = "App Port"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_key_pair" "ratha_key" {
  key_name   = "ratha-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCL1+kiOFL2bBtvjXCbkxWEK/u9mtCh+KscH4+WLo4R0iftKNELkGwbZIxrxPuXLirDdlBujbP1c55JyBVVIAqxCqc5mgAfMDwc4rvPfQpbEhJvfBsLaozwVU6zuuMe5O9wb17AlmWwySRij0r5LgMNWJF76sNXfeJo7+YCBI9zwxZXBBPwILEeOXkjamu1Kybq4HBoART/n7AX75zFPAYd8uKSflKIhH5MBERxj8xN/lNbcVVtxZE9qvuq4klluVts3dLba/rsoHpuHJ9KF0qTe6zP/CfaZLg/9GNynCVNOqk8HFGd+V8iLNBNgKswYHvhgSwjXUETjhNJ3v0Dvtiz ratha@Ratha"
}
resource "aws_instance" "server_1" {
  ami  = "ami-df5de72bdb3b"
  instance_type = "t3.micro"
  count = 1
  key_name = aws_key_pair.ratha_key.key_name
  security_groups = [aws_security_group.sg_1.name]
  user_data = <<-EOF
              #!/bin/bash
              apt update
              apt install git -y
              apt install curl -y

              # Install NVM
              curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
              . ~/.nvm/nvm.sh

              # Install Node.js 18
              nvm install 18

              # Install PM2
              npm install pm2 -g

              # Clone Node.js repository
              git clone  https://github.com/ratha99/devops-cadt.git /root/devops-cadt

              # Navigate to the repository and start the app with PM2
              cd /root/devops-cadt
              npm install
              pm2 start app.js --name node-app -- -p 8000
            EOF
  user_data_replace_on_change = true
}