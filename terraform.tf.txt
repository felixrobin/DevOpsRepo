provider "aws" {
    region = "us-west-2"
    access_key = "AKIA43LPKXIR7F2NVRU6"
    secret_key = "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"
}

resource "aws_instance" "myec2" {
    ami = ami-0ca285d4c2cda3300
    instance_type = t2.micro
}
