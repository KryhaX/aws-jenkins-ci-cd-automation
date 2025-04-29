provider "aws" {
  region = "eu-central-1"
}



resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg-new"
  description = "Security Group for Jenkins Server"
  

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }


  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }


  ingress {
    from_port   = 2375
    to_port     = 2375
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
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


resource "aws_instance" "jenkins" {
  ami             = "ami-04a5bacc58328233d"
  instance_type   = "t2.medium"
  security_groups = [aws_security_group.jenkins_sg.name]
  key_name        = "jenkins-key"

  tags = {
    Name = "Jenkins"
  }


  user_data = <<-EOF
    #!/bin/bash -xe

    ${file("ec2-setup/jenkins-setup.sh")}

    ${file("ec2-setup/aws_cli_setup.sh")}

    ${file("ec2-setup/docker_setup.sh")}
EOF
}

output "JenkinsIP" {
  value       = "http://${aws_instance.jenkins.public_ip}:8080"
}
output "InstanceIP" {
  value       = "${aws_instance.jenkins.public_ip}"
}