"provider" "aws" {}

"resource" "aws_instance" "EC2INSTANCE4" {
  "ami" = "ami-00232ad584ddcf6a4"

  "instance_type" = "t2.micro"
}

