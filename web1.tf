# creating an EC2 instance usign terraform


provider "aws" {
  region = "us-east-1" 
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "default VPC"
  }
}

resource "aws_default_subnet" "default" {
  availability_zone = "us-east-1c"

}

#resource "aws_subnet" "default_1c" {
 # availability_zone = "us-east-1e"
  #cidr_block = "172.31.96.0/24"
  #vpc_id = aws_default_vpc.default.id
#}


#resource "tls_private_key" "key" {
 # algorithm = "RSA"
  #rsa_bits  = 4096
#}

#resource "aws_key_pair" "generated-key" {
  #key_name   = "project"
 # public_key = tls_private_key.key.public_key_openssh
#}


resource "aws_security_group" "myip" {
  name = "project-sg"
  vpc_id = aws_default_vpc.default.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"] # Canonical
}

#module "key_pair" {
 # source = "terraform-aws-modules/key-pair/aws"
# key_name   = "project"
 # public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDGqmCZUNPE1iZusUsIyaxxs0QyMSrZ4g80Hv/EISPsG72Icyn05+W688h4HBcKs7afU4P1fSR6pfjVn0jV0CEWe9pCgYjIg6iTmKPuIrNot/BrZlSebqYKW1gCJtN73zxQWzw0b0IJGjizyYiRg2svPldnoK/PYeiFzjlUQ/quw6jf5ABUAw18Q21Jdb9r3QiUiNB6vfB0g82OcdnQThvQsossajLX6Dcda999I5cV4ucJ1ghb61Ed5pJNujTtF22Q/Wqfsev5xd+1HAzHl/4zTFu0T1ZOwRp3fAaUp5HjKLtgpz29mP5bFdiY9/cMwWrCd+ItHK8+wI5JEge8abu1Qi+86NOh0JwFXduvhW+hHLRH5gYn5JzdWa8KmIq9d4LhFuJEjQprcovQ87vjeFeD39wF+aSq9DwUxrulO1E02NmpCxhvKM2pqTT+8UXzYfqDnzXwqkAWJAVLOFQ0SpG954AdLa62rhh2XhYU5oR7g0X8frw15C1ECERy6v3XKFf5AkxbZELmPpMPAWUH5+M3mdYYFd5ytTk+Us0PcrHI2315a8XsRBOkDmweSAv1LOphXqmyShyrYHQx+T2E1vXtd/yEN8tAOa6SyKoyE3ws2X0Jews7I/1hKxyLuEJ8/qRCqtK42DDdppVAFj9j0z6LrfTZvBmfWNMpOp1lNmwccQ=="
#}

resource "aws_instance" "prod-A" {
  ami = data.aws_ami.ubuntu.id
  availability_zone = "us-east-1e"
  instance_type = "t2.micro"
  user_data     = <<-EOF
                  #!/bin/bash
                  sudo apt-get update
                  sudo apt-get install apache2 -y
                  sudo systemctl restart apache2
                  EOF
  key_name = "project"
  vpc_security_group_ids = [aws_security_group.myip.id]
  subnet_id = aws_default_subnet.default.id
  
}
