# cloud-computing-team21

Terraform infrastructure for the Final Project of the [UPC Cloud Computing Architecture Postgraduate](https://www.talent.upc.edu/ing/estudis/formacio/curs/319401/postgraduate-course-cloud-computing-architecture/) course.

## Network

The infrastructure consists of a single VPC with CIDR block of **10.0.0.0/16**, divided into two Availability Zones (AZ), each one hosting a subnet.

The VPC's CIDR block is divided in two halfs. The first half **10.0.0.0/17** is used for public subnets, and the second half **10.0.128.0/17** for private subnets.

Each half of the CIDR block is further divided among the number of subnets, two public and two private. The public ones having the blocks **10.0.0.0/18** and **10.0.64.0/18**, and the private ones having **10.0.128.0/18** and **10.0.192.0/18**.

This segregation of public and private networks gives more control over network traffic. It allows the implementation of different routing rules and policies for each network range.

## Terraform Usage

### SSH

For connecting to the EC2 instances we use SSH keys. Keys can be created with the following command:

```bash
> ssh-keygen -t rsa -b 4096 -f my_key
```

A private and a public key are created called **my_key** and **my_key.pub**.

The public key must be configured in the EC2 instance, while the private one is used for connecting to it:

```bash
> ssh -i "my_key" user@host
```

### Commands

The following commands validate and create the infrastructure, notice how we set the public key for the EC2 bastion with **bastion_public_key**:

```bash
> cd ./src
> terraform init
> terraform validate
> terraform plan -var='bastion_public_key=path/my_key.pub' \
                 -var='bastion_ingress_cidr_blocks=["0.0.0.0/0"]' \
                 -var='db_username=root' \
                 -var='db_password=my_password'
> terraform apply -var='bastion_public_key=..\keys\terraform-rds' \
                  -var='bastion_ingress_cidr_blocks=["0.0.0.0/0"]' \
                  -var='db_username=root' \
                  -var='db_password=CrearEC2pub' \
                  -auto-approve
```

## Terraform Modules

This repo uses some of the AWS official modules:

- [terraform-aws-modules/vpc/aws](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest)
- [terraform-aws-modules/security-group/aws](https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/latest)
- [terraform-aws-modules/ec2-instance/aws](https://registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws/latest)

As well as custom ones, currently under the **modules** folder:

- [RDS](./src/modules/rds/main.tf)
- [Aurora](./src/modules/aurora/main.tf)
