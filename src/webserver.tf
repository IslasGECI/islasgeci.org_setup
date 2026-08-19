resource "aws_vpc" "webserver" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "webserver-vpc"
  }
}

resource "aws_internet_gateway" "webserver" {
  vpc_id = aws_vpc.webserver.id
  tags = {
    Name = "webserver-igw"
  }
}

resource "aws_subnet" "webserver" {
  vpc_id            = aws_vpc.webserver.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "webserver-subnet"
  }
}

resource "aws_security_group" "webserver" {
  name        = "webserver-sg"
  description = "Security group for webserver"
  vpc_id      = aws_vpc.webserver.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Port 100"
    from_port   = 100
    to_port     = 100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Port 200"
    from_port   = 200
    to_port     = 200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Port 300"
    from_port   = 300
    to_port     = 300
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Port 500"
    from_port   = 500
    to_port     = 500
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

resource "aws_network_interface" "webserver" {
  subnet_id       = aws_subnet.webserver.id
  security_groups = [aws_security_group.webserver.id]

  tags = {
    Name = "webserver-nic"
  }
}

resource "aws_eip" "webserver" {
  domain            = "vpc"
  network_interface = aws_network_interface.webserver.id
  depends_on        = [aws_vpc.webserver]

  tags = {
    Name = "webserver-public-ip"
  }
}

resource "aws_route_table" "webserver" {
  vpc_id = aws_vpc.webserver.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.webserver.id
  }
  tags = {
    Name = "webserver-rt"
  }
}

resource "aws_route_table_association" "webserver" {
  subnet_id      = aws_subnet.webserver.id
  route_table_id = aws_route_table.webserver.id
}

resource "aws_key_pair" "webserver" {
  public_key = file("~/.ssh/id_rsa.pub")
  tags = {
    Name = "webserver-key"
  }
}

resource "aws_instance" "webserver" {
  ami           = "ami-02ebdb11bae1b2486"
  instance_type = "t3.medium"
  key_name      = aws_key_pair.webserver.id

  network_interface {
    network_interface_id = aws_network_interface.webserver.id
    device_index         = 0
  }

  tags = {
    Name = "webserver"
  }

  root_block_device {
    volume_size = 128
    volume_type = "gp3"
  }
}

output "webserver_ip" {
  value = aws_eip.webserver.public_ip
}
