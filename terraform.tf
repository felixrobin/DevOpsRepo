resource "aws_instance" "myec2" {
    ami = ami-0ca285d4c2cda3300
    instance_type = t2.micro
}
