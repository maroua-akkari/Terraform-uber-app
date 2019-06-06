provider "aws" {
  region = "eu-west-1"
}


resource "aws_vpc" "maroua-vpc" {
  cidr_block = "10.135.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "maroua-vpc"
  }
}

resource "aws_subnet" "maroua-public-subnet" {
  vpc_id = "${aws_vpc.maroua-vpc.id}"
  cidr_block = "10.135.1.0/24"

  tags = {
    Name = "Maroua Public Subnet"
  }
}

resource "aws_subnet" "maroua-private-subnet" {
  vpc_id = "${aws_vpc.maroua-vpc.id}"
  cidr_block = "10.135.2.0/24"

  tags = {
    Name = "Maroua Private Subnet"
  }
}

resource "aws_internet_gateway" "maroua-gw" {
  vpc_id = "${aws_vpc.maroua-vpc.id}"

  tags = {
    Name = "Maroua VPC IGW"
  }
}

resource "aws_route_table" "maroua-public-rt" {
  vpc_id = "${aws_vpc.maroua-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.maroua-gw.id}"
  }

  tags = {
    Name = "Maroua Public Subnet RT"
  }
}

resource "aws_route_table_association" "maroua-public-rt" {
  subnet_id = "${aws_subnet.maroua-public-subnet.id}"
  route_table_id = "${aws_route_table.maroua-public-rt.id}"
}

resource "aws_route_table" "maroua-private-rt" {
  vpc_id = "${aws_vpc.maroua-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.maroua-gw.id}"
  }

  tags = {
    Name = "Maroua Private Subnet RT"
  }
}

resource "aws_route_table_association" "maroua-private-rt" {
  subnet_id = "${aws_subnet.maroua-private-subnet.id}"
  route_table_id = "${aws_route_table.maroua-private-rt.id}"
}


resource "aws_security_group" "maroua-public-sg" {
  name = "maroua-public-sg"
  description = "Allow incoming HTTP connections & SSH access"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks =  ["0.0.0.0/0"]
  }

  vpc_id="${aws_vpc.maroua-vpc.id}"

  tags = {
    Name = "Maroua public SG"
  }
}

resource "aws_security_group" "maroua-private-sg"{
  name = "maroua-private-sg"
  description = "Allow traffic from public subnet"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["10.135.1.0/24"]
  }

  vpc_id = "${aws_vpc.maroua-vpc.id}"

  tags = {
    Name = "Maroua Private SG"
  }
}

resource "aws_instance" "public_instance_maroua" {
  ami = "ami-0b45d039456f24807"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.marouaKP.id}"
  subnet_id = "${aws_subnet.maroua-public-subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.maroua-public-sg.id}"]
  associate_public_ip_address = true
  tags = {
    Name = "maroua-app"
  }
}

resource "aws_instance" "private_instance_maroua" {
  ami = "ami-0b45d039456f24807"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.maroua-private-subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.maroua-private-sg.id}"]
  associate_public_ip_address = false
  tags = {
    Name = "maroua-app"
  }
}

resource "aws_key_pair" "marouaKP" {
  key_name = "marouaKP"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}
