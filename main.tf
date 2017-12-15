# Create an EC2 instance
# Install Docker engine
# Download MySQL docker image
# Run MySQL container

provider "aws" {
    version = "~> 1.5"

    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region     = "${var.aws_region}"
}

resource "aws_security_group" "instance" {
  name        = "mysql"
  description = "Allow all inbound traffic"

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "docker-mysql" {
  ami                    = "ami-3dec9947"
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]
  key_name               = "my_dbaas_key"
  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = "${file("my_dbaas_key.pem")}"
  }
  provisioner "remote-exec" {
    inline = [
      "curl -fsSL get.docker.com -o get-docker.sh",
      "sudo sh get-docker.sh",
      "sudo docker pull mysql",
      "sudo docker container run --name=mysql_dbaas -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql"
    ]
  }

  tags {
    Name = "MySQL Server"
  }
}

output "public_ip" {
  value = "${aws_instance.docker-mysql.public_ip}"
}