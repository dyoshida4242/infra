data "aws_ssm_parameter" "amzn2_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_instance" "a" {
  ami                         = data.aws_ssm_parameter.amzn2_ami.value
  instance_type               = "t3.nano"
  key_name                    = "test-hoge" // AWSコンソールで生成したキーペアの名前
  subnet_id                   = aws_subnet.public_1a.id
  security_groups             = [aws_security_group.test.id]
  associate_public_ip_address = true

  tags = {
    Name = "test-ec2-a"
  }
}

resource "aws_instance" "c" {
  ami                         = data.aws_ssm_parameter.amzn2_ami.value
  instance_type               = "t3.nano"
  key_name                    = "test-hoge" // AWSコンソールで生成したキーペアの名前
  subnet_id                   = aws_subnet.public_1c.id
  security_groups             = [aws_security_group.test.id]
  associate_public_ip_address = true

  tags = {
    Name = "test-ec2-c"
  }
}

// security-group
resource "aws_security_group" "test" {
  name        = "test-security-group"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "test-security-group"
  }
}

/// ssh
resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.test.id
}

/// インバウンドルール
resource "aws_security_group_rule" "tcp" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.test.id
}

/// アウトバウンドルール
resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.test.id
}

resource "aws_eip" "a" {
  instance = aws_instance.a.id
  vpc = true

  tags = {
    Name = "test-eip-a"
  }
}

resource "aws_eip" "c" {
  instance = aws_instance.c.id
  vpc = true

  tags = {
    Name = "test-eip-c"
  }
}

data "aws_route53_zone" "main" {
  name         = "d-yoshida.tk"
  private_zone = false
}

resource "aws_route53_record" "main" {
  type = "A"
  name    = "d-yoshida.tk"
  zone_id = data.aws_route53_zone.main.id

  alias {
    name                   = aws_lb.for_webserver.dns_name
    zone_id                = aws_lb.for_webserver.zone_id
    evaluate_target_health = true
  }
}