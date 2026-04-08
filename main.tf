resource "aws_key_pair" "mykey" {
    key_name = "terraform-ansible-key2"
    #public_key = file("C:/Users/username/.ssh/id_rsa.pub")
    public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "ssh-allow" {
    name = "allow-ssh-ansible-2"
    description = "Allow only ssh port"
    ingress {
        from_port = 22
        to_port = 22
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

resource "aws_security_group" "http-allow" {
    name = "allow-http-ansible-2"
    description = "Allow only http port"
    ingress {
        from_port = 80
        to_port = 80
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

resource "aws_security_group" "reactjs-allow" {
    name = "allow-reactjs-2"
    description = "Allow only reactjs port"
    ingress {
        from_port = 30000
        to_port = 30000
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

resource "aws_security_group" "spring-allow" {
    name = "allow-spring-2"
    description = "Allow only spring port"
    ingress {
        from_port = 30081
        to_port = 30081
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

resource "aws_security_group" "mysql-allow" {
    name = "allow-mysql-2"
    description = "Allow only mysql port"
    ingress {
        from_port = 3306
        to_port = 3306
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

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "server" {
    ami = data.aws_ami.amazon_linux.id
    instance_type = "m7i-flex.large"
    key_name = aws_key_pair.mykey.key_name
    root_block_device {
	  volume_size           = 40
	  volume_type           = "gp3"
	  delete_on_termination = true
	  encrypted             = true
    }
    vpc_security_group_ids = [aws_security_group.ssh-allow.id,aws_security_group.http-allow.id,aws_security_group.reactjs-allow.id,aws_security_group.spring-allow.id,aws_security_group.mysql-allow.id]

    connection {
                type     = "ssh"
                user     = "ec2-user"
                private_key = file("~/.ssh/id_rsa")
                host = aws_instance.server.public_ip
        }

	provisioner "remote-exec" {
    		inline = [
			"sudo yum update -y",
			"sudo yum install -y curl wget git",
			"sudo yum install docker -y",
			"sudo systemctl start docker",
			"sudo systemctl enable docker",
			"sudo usermod -aG docker ec2-user",
			#"newgrp docker",
			"curl -LO 'https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl'",
			"chmod +x kubectl",
			"sudo mv kubectl /usr/local/bin",
			"kubectl version --client",
			"curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64",
			"sudo install minikube-linux-amd64 /usr/local/bin/minikube",
			"minikube version",
			"sudo chmod 666 /var/run/docker.sock",
			"minikube start --driver=docker",
  			"sudo hostnamectl set-hostname demo.example.com",
			"curl -LO https://dl.k8s.io/release/v1.35.1/bin/linux/amd64/kubectl",
			"chmod +x kubectl",
			"sudo mv kubectl /usr/local/bin/",
			"kubectl version --client",
			"git clone https://github.com/lavatech321/Kubernetes-Application-Deployment.git",
			"sed -i 's/REPLACE-IP/${self.public_ip}/g' Kubernetes-Application-Deployment/deployment/todo-app-deploy.yaml",
			"kubectl create -f Kubernetes-Application-Deployment/deployment/todo-app-deploy.yaml",
			"sleep 60",
			#"kubectl port-forward service/frontend 30000:3000 --address 0.0.0.0 &",
			#"kubectl port-forward service/backend 30081:7081 --address 0.0.0.0 &",
   		 ]
  	}
}

output "public_ip" {
	value = "Public IP address: ec2-user@${aws_instance.server.public_ip}\n"
}

output "Access-details" {
	value = "ssh -i ~/.ssh/id_rsa ec2-user@${aws_instance.server.public_ip}  \n"
}

output "Kubernetes-Application-Deployment" {
	value = "Application pod server: kubectl get pods \n"
}

output "MYsql-Live" {
	value = "MySQL Credentails: mysql -uappuser -papppass appdb \n"
}

output "Export-port-to-access-the-application" {
	value = " kubectl port-forward service/frontend 30000:3000 --address 0.0.0.0 & \n kubectl port-forward service/backend 30081:7081 --address 0.0.0.0 & \n"
}

output "App-Live" {
	value = "Reactjs and Spring boot Live: http://${aws_instance.server.public_ip}:30000 \n"
}
