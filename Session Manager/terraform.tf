
# resource "aws_instance" "myproject-ec2" {
#     ami = "ami-00785f4835c6acf64"
#     instance_type = "t2.micro"
#     tags = {
#     bu = "itom"
#   }
# }

resource "aws_vpc" "my-project-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  tags = {
    Name = "my-project-vpc"
  }
}

resource "aws_subnet" "my-project-subnet1" {
  vpc_id                  = aws_vpc.my-project-vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name = "my-project-subnet1"
  }

}

resource "aws_subnet" "my-project-subnet2" {
  vpc_id     = aws_vpc.my-project-vpc.id
  cidr_block = "10.0.2.0/24"
  tags = {
    Name = "my-project-subnet2"
  }

}

resource "aws_route_table_association" "route-table-association" {
  subnet_id      = aws_subnet.my-project-subnet1.id
  route_table_id = aws_route_table.my-project-route-table.id
}

resource "aws_route_table" "my-project-route-table" {
  vpc_id = aws_vpc.my-project-vpc.id

  # route {
  #   cidr_block      = "10.0.1.0/24"
  #   vpc_endpoint_id = aws_vpc_endpoint.s3.id
  # }

  # route {
  #   ipv6_cidr_block = "::/0"
  #   gateway_id      = aws_internet_gateway.my-project-gw.id
  # }

  # route {
  #   cidr_block = "0.0.0.0/0"
  #   gateway_id = aws_internet_gateway.my-project-gw.id
  # }
  tags = {
    Name = "project-route-table"
  }


}

# resource "aws_route_table_association" "a" {
#   subnet_id      = aws_subnet.my-project-subnet1.id
#   route_table_id = aws_route_table.my-project-route-table.id
# }

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.my-project-vpc.id
  service_name = "com.amazonaws.eu-west-2.s3"

  tags = {
    Environment = "vpc endpoint test"
  }
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = aws_vpc.my-project-vpc.id
  service_name      = "com.amazonaws.eu-west-2.ssm"
  vpc_endpoint_type = "Interface"
  security_group_ids = [
    aws_security_group.project-security-group.id
  ]
  subnet_ids = [aws_subnet.my-project-subnet1.id]
  tags = {
    Environment = "vpc endpoint ssm"
  }
}

resource "aws_vpc_endpoint" "messages" {
  vpc_id            = aws_vpc.my-project-vpc.id
  service_name      = "com.amazonaws.eu-west-2.ec2messages"
  vpc_endpoint_type = "Interface"
  security_group_ids = [
    aws_security_group.project-security-group.id
  ]
  subnet_ids = [aws_subnet.my-project-subnet1.id]

  tags = {
    Environment = "vpc endpoint ssm"
  }
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id            = aws_vpc.my-project-vpc.id
  service_name      = "com.amazonaws.eu-west-2.ssmmessages"
  vpc_endpoint_type = "Interface"
  security_group_ids = [
    aws_security_group.project-security-group.id
  ]
  subnet_ids = [aws_subnet.my-project-subnet1.id]

  tags = {
    Environment = "vpc endpoint ssm messages"
  }
}


# resource "aws_internet_gateway" "my-project-gw" {
#   vpc_id = aws_vpc.my-project-vpc.id
#   tags = {
#     Name = "my-project-internet-gateway"
#   }
#}

# resource "aws_internet_gateway_attachment" "my-project-gw-attachment" {
#   internet_gateway_id = aws_internet_gateway.my-project-gw.id
#   vpc_id              = aws_vpc.my-project-vpc.id
# }



resource "aws_instance" "webserver" {
  ami = "ami-0fd226841ad6cb023"

  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.my-project-subnet1.id
  vpc_security_group_ids      = [aws_security_group.project-security-group.id]
  iam_instance_profile        = aws_iam_instance_profile.test_profile.name
  associate_public_ip_address = false
#   user_data                   = <<EOF
# !/bin/bash
# #sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
# sudo systemctl start amazon-ssm-agent
# sudo systemctl enable amazon-ssm-agent
# EOF
  tags = {
    Name = "webserver"
  }
}

# resource "aws_eip" "lb" {
#   instance = aws_instance.webserver.id
#   vpc      = true
# }

# resource "aws_eip_association" "eip_assoc" {
#   instance_id   = aws_instance.webserver.id
#   allocation_id = aws_eip.lb.id
# }


# resource "aws_internet_gateway" "gw" {
#   vpc_id = aws_vpc.my-project-vpc.id
# }
 
resource "aws_instance" "dbserver" {
  ami           = "ami-00785f4835c6acf64"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.my-project-subnet2.id
  tags = {
    Name = "Dbserver"
  }

}

resource "aws_security_group" "project-security-group" {
  name        = "project security group"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.my-project-vpc.id

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "https"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "myproject-security group-allow SSH"
  }
}

# resource "aws_iam_instance_profile" "test_profile" {
#   name = "test_profile"
#   role = aws_iam_role.role.name
# }

resource "aws_iam_role" "test_role" {
  name = "test_role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

#Instance Profile
resource "aws_iam_instance_profile" "test_profile" {
  name = "test-ssm-ec2"
  role = aws_iam_role.test_role.name
}

#Attach Policies to Instance Role
resource "aws_iam_policy_attachment" "test_attach1" {
  name       = "test-attachment"
  roles      = [aws_iam_role.test_role.id]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

