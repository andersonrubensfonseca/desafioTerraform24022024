provider "aws" {
  region = "us-east-1"
}

# Criação da VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "my-vpc"
  }
}

# Criação da Subnet
resource "aws_subnet" "my_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"

  tags = {
    Name = "my-subnet"
  }
}

# Criação do Security Group
resource "aws_security_group" "my_security_group" {
  vpc_id = aws_vpc.my_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
}

# Criação da instância EC2
resource "aws_instance" "my_instance" {
  ami           = var.ami 
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.my_subnet.id
  key_name      = var.key_name

  security_groups = [aws_security_group.my_security_group.id]

  tags = {
    Name = "my-instance"
  }

  # Provicionamento para copiar o arquivo index.js
  provisioner "file" {
    source      = "./index.js"
    destination = "/home/ubuntu/index.js"
  }

  # Provicionamento para executar o arquivo index.js
  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/index.js",
      "/home/ubuntu/index.js"
    ]
  }
}

# Criação do Load Balancer
resource "aws_lb" "my_lb" {
  name               = "my-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.my_security_group.id]
  subnets            = [aws_subnet.my_subnet.id]

  enable_deletion_protection = false
}

# Adicione o target group e a associação com a instância EC2
resource "aws_lb_target_group" "my_target_group" {
  name     = "my-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id

  health_check {
    path = "/"
  }
}

resource "aws_lb_listener" "my_listener" {
  load_balancer_arn = aws_lb.my_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.my_target_group.arn
    type             = "forward"
  }
}
