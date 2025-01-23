provider "aws" {
    region = "us-east-1"
}

resource "aws_vpc" "my_vpc" {
    cidr_block = "10.0.0.0/16"

    tags = {
        Name = "my-vpc"
    }
}

resource "aws_subnet" "my_subnet" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.1.0/24"

    tags = {
        Name = "my-subnet"
    }
}

resource "aws_key_pair" "my_key" {
    key_name = "my-new-key"
    public_key = file("C:/Users/Preeti/.ssh/id_rsa.pub")
}

resource "aws_security_group" "allow_ssh" {
    name = "new-launch-wizard-3"
    description = "Allow SSH from my IP and HTTPS from the internet"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["125.16.189.229/32"]
    }

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "myAssignmentServer" {
    ami = "ami-04b4f1a9cf54c11d0"  
    instance_type = "t2.micro"                
    key_name = aws_key_pair.my_key.key_name

    vpc_security_group_ids = [aws_security_group.allow_ssh.id]

    user_data = <<-EOF
                #!/bin/bash
                sudo apt-get update -y
                sudo apt-get install -y docker.io
                sudo systemctl start docker
                sudo systemctl enable docker
                sudo usermod -aG docker ubuntu
                EOF

    tags = {
        Name = "myAssignmentServer"
    }

}