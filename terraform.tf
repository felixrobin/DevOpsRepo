
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
  tags = {
    Name = "my-project-vpc"
  }

}

resource "aws_subnet" "my-project-subnet1" {
  vpc_id                  = aws_vpc.my-project-vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
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

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.my-project-gw.id
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-project-gw.id
  }
  tags = {
    Name = "project-route-table"
  }


}

# resource "aws_route_table_association" "a" {
#   subnet_id      = aws_subnet.my-project-subnet1.id
#   route_table_id = aws_route_table.my-project-route-table.id
# }

# resource "aws_vpc_endpoint" "s3" {
#   vpc_id       = aws_vpc.my-project-vpc.id
#   service_name = "com.amazonaws.eu-west-2.s3"

#   tags = {
#     Environment = "vpc endpoint test"
#   }
# }

resource "aws_internet_gateway" "my-project-gw" {
  vpc_id = aws_vpc.my-project-vpc.id
  tags = {
    Name = "my-project-internet-gateway"
  }

}
# resource "aws_internet_gateway_attachment" "my-project-gw-attachment" {
#   internet_gateway_id = aws_internet_gateway.my-project-gw.id
#   vpc_id              = aws_vpc.my-project-vpc.id
# }



resource "aws_instance" "webserver" {
  ami           = "ami-00785f4835c6acf64"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.my-project-subnet1.id
  vpc_security_group_ids = [aws_security_group.project-security-group.id]
  tags = {
    Name = "webserver"
  }


}

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

