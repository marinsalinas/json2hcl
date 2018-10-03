"data" "aws_availability_zones" "available" {}

"output" "aws_elb_public_dns" {
  "value" = "${aws_elb.web.dns_name}"
}

"provider" "aws" {
  "access_key" = "${var.aws_access_key}"

  "region" = "us-east-1"

  "secret_key" = "${var.aws_secret_key}"
}

"resource" "aws_vpc" "vpc" {
  "cidr_block" = "${var.network_address_space}"
}

"resource" "aws_internet_gateway" "igw" {
  "vpc_id" = "${aws_vpc.vpc.id}"
}

"resource" "aws_subnet" "subnet_sputnik" {
  "availability_zone" = "${data.aws_availability_zones.available.names[0]}"

  "cidr_block" = "${var.sputnik_address_space}"

  "map_public_ip_on_launch" = "true"

  "vpc_id" = "${aws_vpc.vpc.id}"
}

"resource" "aws_route_table" "rtb" {
  "route" = {
    "cidr_block" = "0.0.0.0/0"

    "gateway_id" = "${aws_internet_gateway.igw.id}"
  }

  "vpc_id" = "${aws_vpc.vpc.id}"
}

"resource" "aws_route_table_association" "rta-sputnik" {
  "route_table_id" = "${aws_route_table.rtb.id}"

  "subnet_id" = "${aws_subnet.subnet_sputnik.id}"
}

"resource" "aws_security_group" "sputnik-sg" {
  "egress" = {
    "cidr_blocks" = ["0.0.0.0/0"]

    "from_port" = 0

    "protocol" = "-1"

    "to_port" = 0
  }

  "ingress" = {
    "cidr_blocks" = ["0.0.0.0/0"]

    "from_port" = 22

    "protocol" = "tcp"

    "to_port" = 22
  }

  "ingress" = {
    "cidr_blocks" = ["${var.network_address_space}"]

    "from_port" = 80

    "protocol" = "tcp"

    "to_port" = 80
  }

  "name" = "sputnik_sg"

  "vpc_id" = "${aws_vpc.vpc.id}"
}

"resource" "aws_security_group" "elb-sg" {
  "egress" = {
    "cidr_blocks" = ["0.0.0.0/0"]

    "from_port" = 0

    "protocol" = "-1"

    "to_port" = 0
  }

  "ingress" = {
    "cidr_blocks" = ["0.0.0.0/0"]

    "from_port" = 80

    "protocol" = "tcp"

    "to_port" = 80
  }

  "name" = "nginx_elb_sg"

  "vpc_id" = "${aws_vpc.vpc.id}"
}

"resource" "aws_elb" "web" {
  "instances" = ["${aws_instance.sputnik1.id}", "${aws_instance.sputnik2.id}"]

  "listener" = {
    "instance_port" = 80

    "instance_protocol" = "http"

    "lb_port" = 80

    "lb_protocol" = "http"
  }

  "name" = "nginx-elb"

  "security_groups" = ["${aws_security_group.elb-sg.id}"]

  "subnets" = ["${aws_subnet.subnet_sputnik.id}"]
}

"resource" "aws_instance" "sputnik1" {
  "ami" = "ami-00232ad584ddcf6a4"

  "connection" = {
    "private_key" = "${file("${var.private_key_path}/${var.key_name}")}"

    "user" = "ec2-user"
  }

  "instance_type" = "t2.micro"

  "key_name" = "${var.key_name}"

  "subnet_id" = "${aws_subnet.subnet_sputnik.id}"

  "tags" = {
    "Name" = "tf-moduletwo-sputnik1"
  }

  "vpc_security_group_ids" = ["${aws_security_group.sputnik-sg.id}"]
}

"resource" "aws_instance" "sputnik2" {
  "ami" = "ami-00232ad584ddcf6a4"

  "connection" = {
    "private_key" = "${file(\"${var.private_key_path}/${var.key_name}\")}"

    "user" = "ec2-user"
  }

  "instance_type" = "t2.micro"

  "key_name" = "${var.key_name}"

  "subnet_id" = "${aws_subnet.subnet_sputnik.id}"

  "tags" = {
    "Name" = "tf-moduletwo-sputnik2"
  }

  "vpc_security_group_ids" = ["${aws_security_group.sputnik-sg.id}"]
}

"variable" "aws_access_key" {}

"variable" "aws_secret_key" {}

"variable" "private_key_path" {}

"variable" "key_name" {
  "default" = "dou_key"
}

"variable" "network_address_space" {
  "default" = "10.1.0.0/16"
}

"variable" "sputnik_address_space" {
  "default" = "10.1.0.0/24"
}

"variable" "subnet2_address_space" {
  "default" = "10.1.1.0/24"
}

