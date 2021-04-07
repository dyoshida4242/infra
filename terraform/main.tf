provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "test-vpc"
  }
}

resource "aws_subnet" "public_1a" {
  # 作成したVPCを参照し、そのVPC内にSubnetを立てる
  vpc_id = aws_vpc.main.id
  # Subnetを作成するAZ
  availability_zone = "ap-northeast-1a"
  cidr_block        = "10.0.1.0/24"
  tags = {
    Name = "test-subnet-public-1a"
  }
}

resource "aws_subnet" "public_1c" {
  # 作成したVPCを参照し、そのVPC内にSubnetを立てる
  vpc_id = aws_vpc.main.id
  # Subnetを作成するAZ
  availability_zone = "ap-northeast-1c"
  cidr_block        = "10.0.2.0/24"
  tags = {
    Name = "test-subnet-public-1c"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "test-internet-gateway"
  }
}
