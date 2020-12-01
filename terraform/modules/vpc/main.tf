resource "aws_vpc" "cluster1" {
  cidr_block = "10.27.64.0/18"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    "randomuser.org/usage": "public-cloud"
    "Name": "public-cloud"
  }
}

// general egress
resource "aws_internet_gateway" "public_cloud_gateway" {
  vpc_id = aws_vpc.cluster1.id
  tags = {
    "Name": "public_cloud_gateway"
    "randomuser.org/usage": "egress"
  }
}

// vpn tunnel
resource "aws_customer_gateway" "tuffit_home_tunnel" {
  bgp_asn = "65000"
  ip_address = "98.156.191.126"
  type = "ipsec.1"
  tags = {
    "randomuser.org/usage": "public-cloud"
    "Name": "tuffit_home_tunnel"
  }
}
resource "aws_vpn_gateway" "cluster1_vpc_gateway" {
  vpc_id = aws_vpc.cluster1.id
  tags = { 
    "Name": "cluster1_vpc_gateway"
    "randomuser.org/usage": "public-cloud"
  }
}
resource "aws_vpn_gateway_attachment" "tuffit_public-vpn-attachment" {
  vpc_id = aws_vpc.cluster1.id
  vpn_gateway_id = aws_vpn_gateway.cluster1_vpc_gateway.id
}

resource "aws_vpn_connection" "tuffit_public_connection" {
  vpn_gateway_id = aws_vpn_gateway.cluster1_vpc_gateway.id
  customer_gateway_id = aws_customer_gateway.tuffit_home_tunnel.id
  type = "ipsec.1"
  tunnel1_preshared_key = "you.will.never.guess.it.motherfucker."
  static_routes_only = true
  tags = {
    "Name": "tuffit_public_connection"
    "randomuser.org/usage": "egress"
  }
}
resource "aws_vpn_connection_route" "tuffit_home_route" {
  destination_cidr_block =  "10.27.0.0/20"
  vpn_connection_id =  aws_vpn_connection.tuffit_public_connection.id
}


// public subnets
resource "aws_subnet" "us-west-2a-public-subnet" {
  availability_zone = "us-west-2a"
  cidr_block = "10.27.64.0/22"
  vpc_id = aws_vpc.cluster1.id
  tags = {
    "Name": "us-west-2a-public-subnet"
    "randomuser.org/usage": "egress"
  }
}
resource "aws_subnet" "us-west-2b-public-subnet" {
  availability_zone = "us-west-2b"
  cidr_block = "10.27.68.0/22"
  vpc_id = aws_vpc.cluster1.id
  tags = {
    "Name": "us-west-2b-public-subnet"
    "randomuser.org/usage": "egress"
  }
}
resource "aws_subnet" "us-west-2c-public-subnet" {
  availability_zone = "us-west-2c"
  cidr_block = "10.27.72.0/22"
  vpc_id = aws_vpc.cluster1.id
  tags = {
    "Name": "us-west-2c-public-subnet"
    "randomuser.org/usage": "egress"
  }
}
// 2d is "extra", filling out  10.27.64.0/21 but will not use
resource "aws_subnet" "us-west-2d-public-subnet" {
  availability_zone = "us-west-2d"
  cidr_block = "10.27.76.0/22"
  vpc_id = aws_vpc.cluster1.id
  tags = {
    "Name": "DMZ-us-west-2d-public-subnet"
    "randomuser.org/usage": "utility"
  }
}


// private subnets
resource "aws_subnet" "us-west-2a-private-subnet" {
  availability_zone = "us-west-2a"
  cidr_block = "10.27.80.0/20"
  vpc_id = aws_vpc.cluster1.id
  tags = {
    "Name": "us-west-2a-private-subnet"
    "randomuser.org/usage": "compute"
  }
}
resource "aws_subnet" "us-west-2b-private-subnet" {
  availability_zone = "us-west-2b"
  cidr_block = "10.27.96.0/20"
  vpc_id = aws_vpc.cluster1.id
  tags = {
    "Name": "us-west-2b-private-subnet"
    "randomuser.org/usage": "compute"
  }
}
resource "aws_subnet" "us-west-2c-private-subnet" {
  availability_zone = "us-west-2c"
  cidr_block = "10.27.112.0/20"
  vpc_id = aws_vpc.cluster1.id
  tags = {
    "Name": "us-west-2c-private-subnet"
    "randomuser.org/usage": "compute"
  }
}

// -- enable egress from from private subnets
// EIPs for each subnet's gateway
resource "aws_eip" "us-west-2a-ngw-eip" {
  vpc = true
  tags = {
    "Name": "us-west-2a-ngw-eip"
    "randomuser.org/usage": "egress"
  }
}
resource "aws_eip" "us-west-2b-ngw-eip" {
  vpc = true
  tags = {
    "Name": "us-west-2b-ngw-eip"
    "randomuser.org/usage": "egress"
  }
}
resource "aws_eip" "us-west-2c-ngw-eip" {
  vpc = true
  tags = {
    "Name": "us-west-2c-ngw-eip"
    "randomuser.org/usage": "egress"
  }
}

// nat gateway for each az
resource "aws_nat_gateway" "us-west-2a-ngw" {
  allocation_id = aws_eip.us-west-2a-ngw-eip.id
  subnet_id = aws_subnet.us-west-2a-public-subnet.id
  tags = {
    "randomuser.org/usage": "egress"
    "Name": "us-west-2a-ngw"
  }
}
resource "aws_nat_gateway" "us-west-2b-ngw" {
  allocation_id = aws_eip.us-west-2b-ngw-eip.id
  subnet_id = aws_subnet.us-west-2b-public-subnet.id
  tags = {
    "randomuser.org/usage": "egress"
    "Name": "us-west-2b-ngw"
  }
}
resource "aws_nat_gateway" "us-west-2c-ngw" {
  allocation_id = aws_eip.us-west-2c-ngw-eip.id
  subnet_id = aws_subnet.us-west-2c-public-subnet.id
  tags = {
    "randomuser.org/usage": "egress"
    "Name": "us-west-2c-ngw"
  }
}

// -- subnet routing tables
// public routing tables, defined
resource "aws_route_table" "us-west-2a-public-route" {
  vpc_id = aws_vpc.cluster1.id
  route {
    cidr_block = "10.27.0.0/20"
    gateway_id = aws_vpn_gateway.cluster1_vpc_gateway.id
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public_cloud_gateway.id
  }
  tags = { 
    "Name": "us-west-2a_public_route"
    "randomuser.org/usage": "egress"
  }
}
resource "aws_route_table" "us-west-2b-public-route" {
  vpc_id = aws_vpc.cluster1.id
  route {
    cidr_block = "10.27.0.0/20"
    gateway_id = aws_vpn_gateway.cluster1_vpc_gateway.id
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public_cloud_gateway.id
  }
  tags = { 
    "Name": "us-west-2b_public_route"
    "randomuser.org/usage": "egress"
  }
}
resource "aws_route_table" "us-west-2c-public-route" {
  vpc_id = aws_vpc.cluster1.id
  route {
    cidr_block = "10.27.0.0/20"
    gateway_id = aws_vpn_gateway.cluster1_vpc_gateway.id
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public_cloud_gateway.id
  }
  tags = { 
    "Name": "us-west-2c_public_route"
    "randomuser.org/usage": "egress"
  }
}
resource "aws_route_table" "us-west-2d-public-route" {
  vpc_id = aws_vpc.cluster1.id
  route {
    cidr_block = "10.27.0.0/20"
    gateway_id = aws_vpn_gateway.cluster1_vpc_gateway.id
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public_cloud_gateway.id
  }
  tags = { 
    "Name": "us-west-2d_public_route"
    "randomuser.org/usage": "egress"
  }
}

// associate public routes with public subnets
resource "aws_route_table_association" "us-west-2a-public-routeassoc" {
  subnet_id = aws_subnet.us-west-2a-public-subnet.id
  route_table_id = aws_route_table.us-west-2a-public-route.id
}
resource "aws_route_table_association" "us-west-2b-public-routeassoc" {
  subnet_id = aws_subnet.us-west-2b-public-subnet.id
  route_table_id = aws_route_table.us-west-2b-public-route.id
}
resource "aws_route_table_association" "us-west-2c-public-routeassoc" {
  subnet_id = aws_subnet.us-west-2c-public-subnet.id
  route_table_id = aws_route_table.us-west-2c-public-route.id
}
resource "aws_route_table_association" "us-west-2d-public-routeassoc" {
  subnet_id = aws_subnet.us-west-2d-public-subnet.id
  route_table_id = aws_route_table.us-west-2d-public-route.id
}


// private routes, defined
resource "aws_route_table" "us-west-2a-private-route" {
  vpc_id = aws_vpc.cluster1.id
  route {
    cidr_block = "10.27.0.0/20"
    gateway_id = aws_vpn_gateway.cluster1_vpc_gateway.id
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.us-west-2a-ngw.id
  }
  tags = { 
    "Name": "us-west-2a_private_route"
    "randomuser.org/usage": "compute"
  }
}
resource "aws_route_table" "us-west-2b-private-route" {
  vpc_id = aws_vpc.cluster1.id
  route {
    cidr_block = "10.27.0.0/20"
    gateway_id = aws_vpn_gateway.cluster1_vpc_gateway.id
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.us-west-2b-ngw.id
  }
  tags = { 
    "Name": "us-west-2b_private_route"
    "randomuser.org/usage": "compute"
  }
}
resource "aws_route_table" "us-west-2c-private-route" {
  vpc_id = aws_vpc.cluster1.id
  route {
    cidr_block = "10.27.0.0/20"
    gateway_id = aws_vpn_gateway.cluster1_vpc_gateway.id
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.us-west-2c-ngw.id
  }
  tags = { 
    "Name": "us-west-2c_private_route"
    "randomuser.org/usage": "compute"
  }
}

// private route tables, associated
resource "aws_route_table_association" "us-west-2a-private-routeassoc" {
  subnet_id = aws_subnet.us-west-2a-private-subnet.id
  route_table_id = aws_route_table.us-west-2a-private-route.id
}
resource "aws_route_table_association" "us-west-2b-private-routeassoc" {
  subnet_id = aws_subnet.us-west-2b-private-subnet.id
  route_table_id = aws_route_table.us-west-2b-private-route.id
}
resource "aws_route_table_association" "us-west-2c-private-routeassoc" {
  subnet_id = aws_subnet.us-west-2c-private-subnet.id
  route_table_id = aws_route_table.us-west-2c-private-route.id
}




output "vpc_id" { 
  value = aws_vpc.cluster1.id 
}

// output subnet IDs

output "us-west-2a-public-subnet_id" {
  value = aws_subnet.us-west-2a-public-subnet.id
}
output "us-west-2b-public-subnet_id" {
  value = aws_subnet.us-west-2b-public-subnet.id
}
output "us-west-2c-public-subnet_id" {
  value = aws_subnet.us-west-2c-public-subnet.id
}
output "us-west-2d-public-subnet_id" {
  value = aws_subnet.us-west-2d-public-subnet.id
}
output "dmz_subnet" {
  value = aws_subnet.us-west-2d-public-subnet.id
}
output "us-west-2a-private-subnet_id" {
  value = aws_subnet.us-west-2a-private-subnet.id
}
output "us-west-2b-private-subnet_id" {
  value = aws_subnet.us-west-2b-private-subnet.id
}
output "us-west-2c-private-subnet_id" {
  value = aws_subnet.us-west-2c-private-subnet.id
}
