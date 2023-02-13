provider "aws" {
access_key = "access_key"
secret_key = "secret_key"
region = "ap-south-1"
}
# Creating VPC
resource "aws_vpc" "demovpc" {
  cidr_block       = "${var.vpc_cidr}"
  instance_tenancy = "default"

tags = {
  Name = "Demo VPC"
}
}

# Creating 1st web subnet

resource "aws_subnet" "public-subnet-1" {
  vpc_id                  = "${aws_vpc.demovpc.id}"
  cidr_block             = "${var.subnet_cidr}"
  map_public_ip_on_launch = true
  availability_zone = "ap-south-1a"

tags = {
  Name = "Web Subnet 1"
}
}
# Creating Internet Gateway

resource "aws_internet_gateway" "demogateway" {
  vpc_id = "${aws_vpc.demovpc.id}"
}
# Creating Route Table

resource "aws_route_table" "route" {
  vpc_id = "${aws_vpc.demovpc.id}"

route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.demogateway.id}"
  }

tags = {
      Name = "Route to internet"
  }
}

# Associating Route Table

resource "aws_route_table_association" "rt1" {
  subnet_id = "${aws_subnet.public-subnet-1.id}"
  route_table_id = "${aws_route_table.route.id}"
}
# Creating 1st EC2 instance in Public Subnet
resource "aws_instance" "demoinstance" {
  ami                         = "ami-01a4f99c4ac11b03c"
  instance_type               = "t2.micro"
  key_name                    = "aws"
  vpc_security_group_ids      = ["${aws_security_group.demosg.id}"]
  subnet_id                   = "${aws_subnet.public-subnet-1.id}"
  associate_public_ip_address = true
  user_data                   = "${file("jenkins.sh")}"

tags = {
  Name = "My Public Instance"
}
}

# Creating Security Group

resource "aws_security_group" "demosg" {
  vpc_id = "${aws_vpc.demovpc.id}"
                                
# Inbound Rules
# HTTP access from anywhere

 ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]
}

# Outbound Rules
# Internet access to anywhere
egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

tags = {
  Name = "Web SG"
}
}

# Defining CIDR Block for VPC

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

# Defining CIDR Block for 1st Subnet

variable "subnet_cidr" {
  default = "10.0.1.0/24"
}
