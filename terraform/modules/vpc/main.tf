resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true 

tags = {
    Name = "${local.env}-main"
}
}

resource "aws_subnet" "all" {
  for_each = var.subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = each.value.type == "public"

  tags = merge(
    { Name = each.key },
    each.value.type == "public"
      ? var.public_subnet_tags
      : var.private_subnet_tags
  )
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${local.env}-igw"
  }
}


resource "aws_eip" "main" {
  domain   = "vpc"
  depends_on = [aws_internet_gateway.igw]
  
  tags = {
    Name = "${local.env}-nat"
  }
}

resource "aws_nat_gateway" "ng" {
  allocation_id = aws_eip.main.id
  subnet_id     = aws_subnet.all["public-1"].id

  tags = {
    Name = "${local.env}-nat"
  }
  depends_on = [aws_internet_gateway.igw]
}


resource "aws_route_table" "rt-public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id 
  }


  tags = {
    Name = "${local.env}-public"
  }
}



resource "aws_route_table" "rt-private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ng.id  
  }


  tags = {
    Name = "${local.env}-private" 

  }
}

resource "aws_route_table_association" "public" {
  for_each = toset(["public-1", "public-2"])
  subnet_id      =  aws_subnet.all[each.key].id
  route_table_id = aws_route_table.rt-public.id
}



resource "aws_route_table_association" "private" {
   for_each = toset(["private-1", "private-2"])
  subnet_id      =  aws_subnet.all[each.key].id
  route_table_id = aws_route_table.rt-private.id
}


