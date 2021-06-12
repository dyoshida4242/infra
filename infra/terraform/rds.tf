resource "aws_subnet" "private_db_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = "tf_private_db1"
  }
}

resource "aws_subnet" "private_db_c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "ap-northeast-1c"
  tags = {
    Name = "tf_private_db2"
  }
}

resource "aws_security_group" "db" {
  name        = "db_server"
  description = "It is a security group on db of tf_vpc."
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "test_db"
  }
}

resource "aws_security_group_rule" "db" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.test.id
  security_group_id        = aws_security_group.db.id  // パブリックサブネットからのアクセスを許可するために必要
}

resource "aws_db_subnet_group" "db_subnet" {
  name        = "test_db_subnet"
  description = "It is a DB subnet group on tf_vpc."
  subnet_ids  = [aws_subnet.private_db_a.id, aws_subnet.private_db_c.id]

  tags = {
    Name = "test_db_subnet"
  }
}

resource "aws_db_instance" "main" {
  identifier                  = "test-db"
  allocated_storage           = 20
  storage_type                = "gp2"
  engine                      = "mysql"
  engine_version              = "8.0.20"
  instance_class              = "db.t2.micro"
  username                    = "root"
  password                    = "password"
  skip_final_snapshot         = true // RDS削除時にsnapshotを作成しない
  multi_az                    = true
  db_subnet_group_name        = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids      = [aws_security_group.db.id]

  tags = {
    Name = "tf_instance"
  }
}
