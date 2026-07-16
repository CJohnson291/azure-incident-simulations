terraform {
  backend "s3" {
    bucket         = "cj-tfstate-incidentsim"
    key            = "aws-incidentsim.terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "cj-tfstate-lock"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_vpc" "main" {
  cidr_block           = "10.60.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name    = "${var.prefix}-vpc"
    project = "incident-simulation-aws"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "${var.prefix}-igw"
    project = "incident-simulation-aws"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.60.1.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.prefix}-subnet-public"
    project = "incident-simulation-aws"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name    = "${var.prefix}-rt-public"
    project = "incident-simulation-aws"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "app1" {
  name        = "${var.prefix}-sg-app1"
  description = "Security group for App 1"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.prefix}-sg-app1"
    project = "incident-simulation-aws"
  }
}

resource "aws_key_pair" "app1" {
  key_name   = "${var.prefix}-keypair"
  public_key = var.ssh_public_key
}

resource "aws_instance" "app1" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.app1.id]
  key_name                    = aws_key_pair.app1.key_name
  user_data                   = file("${path.module}/user-data.sh")
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile.name

  tags = {
    Name    = "${var.prefix}-app1"
    project = "incident-simulation-aws"
    app     = "app1"
  }
}

resource "aws_eip" "app1" {
  instance = aws_instance.app1.id
  domain   = "vpc"

  tags = {
    Name    = "${var.prefix}-eip-app1"
    project = "incident-simulation-aws"
  }
}

resource "aws_iam_role" "ssm_role" {
  name = "${var.prefix}-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "${var.prefix}-ec2-ssm-profile"
  role = aws_iam_role.ssm_role.name
}