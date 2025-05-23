resource "aws_vpc" "myvpc" {
  cidr_block = var.my_cidr
}

resource "aws_subnet" "sub1" {
  vpc_id = aws_vpc.myvpc.id
  availability_zone = "ap-south-1a"
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "sub2" {
  vpc_id = aws_vpc.myvpc.id
  availability_zone = "ap-south-1b"
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.myvpc.id
}

resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}
resource "aws_route_table_association" "rta1" {
  subnet_id = aws_subnet.sub1.id
  route_table_id = aws_route_table.rt1.id
}
resource "aws_route_table_association" "rta2" {
  subnet_id = aws_subnet.sub2.id
  route_table_id = aws_route_table.rt1.id
}

resource "aws_security_group" "webSg" {
  name = "web"
  vpc_id = aws_vpc.myvpc.id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Allow HTTP "
    }
   ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Allow SSH "
    }
   egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    }
    tags = {
        Name = "webSg"
    }
}

resource "aws_s3_bucket" "example" {
  bucket = "my-test-bucekt-0110"
}
resource "aws_instance" "webserver-1" {
  ami = "ami-0261755bbcb8c4a84"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.webSg.id]
  subnet_id = aws_subnet.sub1.id
  user_data = file("userdata.sh")
}

resource "aws_instance" "webserver-2" {
  ami = "ami-0261755bbcb8c4a84"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.webSg.id]
  subnet_id = aws_subnet.sub2.id
  user_data = file("userdata.sh")
}

resource "aws_lb" "myalb" {
  name = "myalb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.webSg.id]
  subnets = [aws_subnet.sub1.id,aws_subnet.sub2.id]

  tags = {
    Name  ="web"
  }
}

resource "aws_lb_target_group" "tg" {
  name = "myTG"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.myvpc.id
  
  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id = aws_instance.webserver-1.id
}

resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id = aws_instance.webserver-2.id
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.myalb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.tg.arn
    type = "forward"
  }
}

output "loadbalancerdns" {
  value = aws_lb.myalb.dns_name
}