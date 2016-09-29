---
title: "Terraform: AWS VPC with Private and Public Subnets"
published: 2015-07-08 22:56:07 +0000
tags: terraform, amazon-web-services
---

I'm currently in the process of designing out the architecture for a project
which is soon to be hosted on [AWS][]. My aim has been to isolate groups of
components (like [Redis][] and/or [Postgres][] instances) from other groups
(like web application servers) as much as possible to restrict access.

AWS provides [VPC][] (Virtual Private Cloud) to do such a thing, but it's quite
fiddly to get going. This is where [Terraform][] steps in. Terraform is a tool
that allows you to automate your interactions with services like AWS (and
indeed others) and record the state, giving you the ability to place your
infrastructure in source control.

In the AWS documentation, this is given as an example: "[Scenario 2][]" and
this post will show how this can be replicated using Terraform. I'd recommend
you familiarise yourself with the AWS documentation's version first and also
get a good understanding of [Terraform from it's
documentation][terraform_docs]. You can find a [repository with the full
example over on GitHub][full_example].

### Terraform, Briefly

Terraform abstracts out the interaction with various infrastructure services
(AWS, Digital Ocean, OpenStack, etc) and provides a unified configuration
format for it.

As the Terraform docs point out, the best way to show it is through examples,
but a few important points:

* `.tf` files are all combined to provide the full configuration.
    - This gives us a handy way to break the configuration up into thematic
      sections.
* `.tfstate` and `.tfstate.backup` holds the last-known state of the
  infrastructure, you'll want to store this, too.
* `.tfvars` contain values for the declared variables, typically called:
  `terraform.tfvars`.

To see what Terraform will do: `terraform plan -var-file terraform.tfvars`

To bring up the infrastructure we'll run: `terraform apply -var-file
terraform.tfvars`

And to destroy it, we'll run: `terraform destroy -var-file terraform.tfvars`

### Infrastructure Aims

<figure>
  <img src="/resources/images/aws_terraform_network_diagram.png" alt="AWS's
  Scenario 2 Network Diagram" max-with="500px">
  <figcaption>AWS's Scenario 2 Network Diagram</figcaption>
</figure>

The network diagram above is the best demonstration of what'll be implemented:

* The private subnet is inaccessible to the internet (both in and out).
* The public subnet is accessible; just dependent on the configuration of the
  security groups. Elastic IPs can be associated with instances in here.
* Instances in the public subnet can access instances in the private subnet
  (also dependent on security groups) because they're in the same VPC (this is
  enabled by the route tables).
* Routing is handled like this:
    - Private subnet is routed through the NAT instance.
    - Public subnet is routed directly to the internet gateway.

### Implementing in Terraform

In my implementation, I've opted to split the configuration into files broken
by what they do. I feel this is the one of the great strengths of the Terraform
configuration format, and, I find makes it much easier to track changes.

Additionally, I've liberalised some of the security groups compared to the
original (allowing connections via `SSH` from anywhere and allowing ICMP
packets). This is also specified to use Ubuntu 14.04 instances in the
`eu-west-1` (Ireland) region

#### `variables.tf`

This file is typically called `variables.tf` by convention. It's typically full
of environment specific configuration, like which `ami` to use and which
credentials to use.

```ruby
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_key_path" {}
variable "aws_key_name" {}

variable "aws_region" {
    description = "EC2 Region for the VPC"
    default = "eu-west-1"
}

variable "amis" {
    description = "AMIs by region"
    default = {
        eu-west-1 = "ami-f1810f86" # ubuntu 14.04 LTS
    }
}

variable "vpc_cidr" {
    description = "CIDR for the whole VPC"
    default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
    description = "CIDR for the Public Subnet"
    default = "10.0.0.0/24"
}

variable "private_subnet_cidr" {
    description = "CIDR for the Private Subnet"
    default = "10.0.1.0/24"
}
```

Outside of the authentication credentials, here we've configured the default
AMI and the default region to use. Then the [CIDR][] blocks for the VPC overall
and the two subnets contained within it.

#### `terraform.tfvars`

This is the file which is passed into each command, and provides the "secrets"
and more specific values.

```ruby
aws_access_key = ""
aws_secret_key = ""
aws_key_path = "~/.ssh/aws.pem"
aws_key_name = "aws"
```

(The key should be already configured with AWS.)

#### `aws.tf`

This configures the provider, note how it uses string interpolation to pull
out the variables from previously:

```ruby
provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.aws_region}"
}
```

#### `vpc.tf`

This is the largest of the lot and configures both the VPC, the NAT instance,
the two subnets and the relevant security groups.

```ruby
resource "aws_vpc" "default" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = true
    tags {
        Name = "terraform-aws-vpc"
    }
}

resource "aws_internet_gateway" "default" {
    vpc_id = "${aws_vpc.default.id}"
}

/*
  NAT Instance
*/
resource "aws_security_group" "nat" {
    name = "vpc_nat"
    description = "Allow traffic to pass from the private subnet to the internet"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["${var.private_subnet_cidr}"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["${var.private_subnet_cidr}"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${var.vpc_cidr}"]
    }
    egress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = "${aws_vpc.default.id}"

    tags {
        Name = "NATSG"
    }
}

resource "aws_instance" "nat" {
    ami = "ami-30913f47" # this is a special ami preconfigured to do NAT
    availability_zone = "eu-west-1a"
    instance_type = "m1.small"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${aws_security_group.nat.id}"]
    subnet_id = "${aws_subnet.eu-west-1a-public.id}"
    associate_public_ip_address = true
    source_dest_check = false

    tags {
        Name = "VPC NAT"
    }
}

resource "aws_eip" "nat" {
    instance = "${aws_instance.nat.id}"
    vpc = true
}

/*
  Public Subnet
*/
resource "aws_subnet" "eu-west-1a-public" {
    vpc_id = "${aws_vpc.default.id}"

    cidr_block = "${var.public_subnet_cidr}"
    availability_zone = "eu-west-1a"

    tags {
        Name = "Public Subnet"
    }
}

resource "aws_route_table" "eu-west-1a-public" {
    vpc_id = "${aws_vpc.default.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.default.id}"
    }

    tags {
        Name = "Public Subnet"
    }
}

resource "aws_route_table_association" "eu-west-1a-public" {
    subnet_id = "${aws_subnet.eu-west-1a-public.id}"
    route_table_id = "${aws_route_table.eu-west-1a-public.id}"
}

/*
  Private Subnet
*/
resource "aws_subnet" "eu-west-1a-private" {
    vpc_id = "${aws_vpc.default.id}"

    cidr_block = "${var.private_subnet_cidr}"
    availability_zone = "eu-west-1a"

    tags {
        Name = "Private Subnet"
    }
}

resource "aws_route_table" "eu-west-1a-private" {
    vpc_id = "${aws_vpc.default.id}"

    route {
        cidr_block = "0.0.0.0/0"
        instance_id = "${aws_instance.nat.id}"
    }

    tags {
        Name = "Private Subnet"
    }
}

resource "aws_route_table_association" "eu-west-1a-private" {
    subnet_id = "${aws_subnet.eu-west-1a-private.id}"
    route_table_id = "${aws_route_table.eu-west-1a-private.id}"
}
```

The NAT instance is a special Amazon Linux AMI which handles the routing
correctly. It can be found on the AWS Marketplace using the `aws` command line
tool by doing something like this:

```sh
aws ec2 describe-images --filter Name="owner-alias",Values="amazon" --filter
Name="name",Values="amzn-ami-vpc-nat*"
```

Like all AMIs, there's specific images for each region.

#### `public.tf`

This file (and the next) is where I'd split the file structure into more
specific sections (like a `web.tf` or `application.tf`) instead of just the
single `public.tf` in a larger implementation, as this is where much of the
detail will be described. It works good enough here, as we'll just be
implementing a single instance and security group in each subnet.

```ruby
/*
  Web Servers
*/
resource "aws_security_group" "web" {
    name = "vpc_web"
    description = "Allow incoming HTTP connections."

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress { # SQL Server
        from_port = 1433
        to_port = 1433
        protocol = "tcp"
        cidr_blocks = ["${var.private_subnet_cidr}"]
    }
    egress { # MySQL
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = ["${var.private_subnet_cidr}"]
    }

    vpc_id = "${aws_vpc.default.id}"

    tags {
        Name = "WebServerSG"
    }
}

resource "aws_instance" "web-1" {
    ami = "${lookup(var.amis, var.aws_region)}"
    availability_zone = "eu-west-1a"
    instance_type = "m1.small"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${aws_security_group.web.id}"]
    subnet_id = "${aws_subnet.eu-west-1a-public.id}"
    associate_public_ip_address = true
    source_dest_check = false


    tags {
        Name = "Web Server 1"
    }
}

resource "aws_eip" "web-1" {
    instance = "${aws_instance.web-1.id}"
    vpc = true
}
```

#### `private.tf`

```ruby
/*
  Database Servers
*/
resource "aws_security_group" "db" {
    name = "vpc_db"
    description = "Allow incoming database connections."

    ingress { # SQL Server
        from_port = 1433
        to_port = 1433
        protocol = "tcp"
        security_groups = ["${aws_security_group.web.id}"]
    }
    ingress { # MySQL
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        security_groups = ["${aws_security_group.web.id}"]
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${var.vpc_cidr}"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["${var.vpc_cidr}"]
    }

    egress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = "${aws_vpc.default.id}"

    tags {
        Name = "DBServerSG"
    }
}

resource "aws_instance" "db-1" {
    ami = "${lookup(var.amis, var.aws_region)}"
    availability_zone = "eu-west-1a"
    instance_type = "m1.small"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${aws_security_group.db.id}"]
    subnet_id = "${aws_subnet.eu-west-1a-private.id}"
    source_dest_check = false

    tags {
        Name = "DB Server 1"
    }
}
```

### Bring it up & Testing

Once you've defined the environment configuration files, it's time to bring it
up. You can do that by firing off:

```sh
terraform apply -var-file terraform.tfvars
```

That'll bring up the VPC, all of the security groups, the NAT instance and
finally the Web and DB instances. You'll then have a set of machines like so:

| Instance Name | Private IP | Public IP    |
|---------------|------------|--------------|
| VPC NAT       | 10.0.0.210 | 52.16.161.59 |
| Web Server 1  | 10.0.0.37  | 52.16.185.18 |
| DB Server 1   | 10.0.1.22  | n/a          |

(Obviously, with different values).

Our security groups allow us to connect through the NAT intuance to the other
instances inside the private subnet. I'd recommend configuring a separate
instance for this, which is typically known as a "bastion". But, to keep it
simple, adjusting the security groups is enough for this case.

Connect to the NAT instance, also using agent forwarding so we can reuse the
session:

```sh
ssh -i ~/.ssh/key_name.pem -A ec2-user@52.16.161.59
```

And then inside the NAT instance, you'll be able to connect to either of the
other two instances:

```sh
# Web Server 1
ssh ubuntu@10.0.0.37
# DB Server 1
ssh ubuntu@10.0.1.22
```

The nuance of AWS security groups are out of scope for this article, but in
general, you'll need to define a "egress" route for packets leaving an instance
and an "ingress" to define them going into (another) one. This gives you a
pretty powerful way to lock down access to specific instance groups.

But, that's it. You've now defined the state of an infrastructure in a group of
files, bought it all up in a single command and can track future changes with
it. All following Amazon's example "Scenario 2".

[AWS]: http://aws.amazon.com/
[Redis]: http://redis.io
[Postgres]: http://www.postgresql.org
[VPC]: http://aws.amazon.com/documentation/vpc/
[Terraform]: http://terraform.io
[Scenario 2]: http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Scenario2.html
[terraform_docs]: https://terraform.io/intro/
[full_example]: https://github.com/nickcharlton/terraform-aws-vpc
[CIDR]: https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing
