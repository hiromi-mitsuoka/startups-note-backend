resource "aws_vpc" "startups" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true # AWSのDNSサーバーによる名前解決を有効
  enable_dns_hostnames = true # VPC内のリソースにパブリックDNSホスト名を自動割り当て

  tags = {
    Name = "startups"
  }
}

resource "aws_subnet" "public_1a" {
  vpc_id = aws_vpc.startups.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true # このサブネットで起動したインスタンスにパブリックIPアドレスを自動割り当て
  availability_zone = "ap-northeast-1a"
}

resource "aws_subnet" "public_1c" {
  vpc_id = aws_vpc.startups.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-northeast-1c"
}

resource "aws_internet_gateway" "startups" {
  vpc_id = aws_vpc.startups.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.startups.id

  # ルートテーブルでは、VPC内の通信を有効にするため、ローカルルートが自動作成される
  # VPC内はこのローカルルートによりルーティングされ、ローカルルートは変更は削除ができない
  # Terraformからも制御できない
}

# ルート（ルートテーブルの1レコード）
resource "aws_route" "public" {
  route_table_id = aws_route_table.public.id
  gateway_id = aws_internet_gateway.startups.id
  destination_cidr_block = "0.0.0.0/0"

  # VPC以外への通信を、インターネットゲートウェイ経由でインターネットへ流す
}

# ルートテーブルとサブネットを関連付け
resource "aws_route_table_association" "public_1a" {
  subnet_id = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public.id

  # 関連付けを忘れた場合は、デフォルトルートテーブルが自動作成され使用（アンチパターン）
}

resource "aws_route_table_association" "public_1c" {
  subnet_id = aws_subnet.public_1c.id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "private_1a" {
  vpc_id = aws_vpc.startups.id
  cidr_block = "10.0.65.0/24"
  availability_zone = "ap-northeast-1a"
  map_public_ip_on_launch = false # パブリックIPアドレス不要
}

resource "aws_subnet" "private_1c" {
  vpc_id = aws_vpc.startups.id
  cidr_block = "10.0.66.0/24"
  availability_zone = "ap-northeast-1c"
  map_public_ip_on_launch = false
}

# デフォルトルートは一つのルートテーブルにつき、一つしか定義できないため、ルートテーブルもマルチAZ化
resource "aws_route_table" "private_1a" {
  vpc_id = aws_vpc.startups.id
}

resource "aws_route_table" "private_1c" {
  vpc_id = aws_vpc.startups.id
}

# プライベートネットワークからインターネットへ通信するためのルート
resource "aws_route" "private_1a" {
  route_table_id = aws_route_table.private_1a.id
  nat_gateway_id = aws_nat_gateway.nat_gateway_1a.id # プライベートルートの場合は、gateway_idでないことに注意
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "private_1c" {
  route_table_id = aws_route_table.private_1c.id
  nat_gateway_id = aws_nat_gateway.nat_gateway_1c.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "private_1a" {
  subnet_id = aws_subnet.private_1a.id
  route_table_id = aws_route_table.private_1a.id
}

resource "aws_route_table_association" "private_1c" {
  subnet_id = aws_subnet.private_1c.id
  route_table_id = aws_route_table.private_1c.id
}

# NATゲートウェイ用のElastic IP
resource "aws_eip" "nat_gateway_1a" {
  vpc = true
  depends_on = [aws_internet_gateway.startups]
}

resource "aws_eip" "nat_gateway_1c" {
  vpc = true
  depends_on = [aws_internet_gateway.startups]
}

# NATゲートウェイ単体の場合、片方のAZ障害時もう片方のAZでも通信ができなくなるため、マルチAZ化
resource "aws_nat_gateway" "nat_gateway_1a" {
  allocation_id = aws_eip.nat_gateway_1a.id # EIP指定
  subnet_id = aws_subnet.public_1a.id # NATゲートウェイを配置するパブリックサブネット指定
  depends_on = [aws_internet_gateway.startups] # インターネットゲートウェイと紐付けを明示（推奨）
}

resource "aws_nat_gateway" "nat_gateway_1c" {
  allocation_id = aws_eip.nat_gateway_1c.id
  subnet_id = aws_subnet.public_1c.id
  depends_on = [aws_internet_gateway.startups]
}