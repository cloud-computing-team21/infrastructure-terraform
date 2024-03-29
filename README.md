# infrastructure-terraform

Terraform infrastructure for the Final Project of the [UPC Cloud Computing Architecture Postgraduate](https://www.talent.upc.edu/ing/estudis/formacio/curs/319401/postgraduate-course-cloud-computing-architecture/) course.

## Terraform Usage

### SSH

For connecting to the EC2 instances we use SSH keys. Keys can be created with the following command:

```bash
> ssh-keygen -t rsa -b 4096 -f my_key
```

A private and a public key are created called **my_key** and **my_key.pub**.

The public key is configured in the EC2 instance through Terraform, while the private one is used for connecting to it:

```bash
> ssh -i "my_key" user@host
```

### Commands

The following commands validate and create the infrastructure, notice how we set the public key for the EC2 bastion with **bastion_public_key**:

```bash
> cd ./src
> terraform init
> terraform validate
> terraform plan/apply
            -var='public_key=../.keys/my_key.pub' \
            -var='bastion_ingress_cidr_blocks=["0.0.0.0/0"]' \
            -var='bastion_user_data_file=../user-data/bastion-ubuntu.sh' \
            -var='eks_iam_role_arn=arn:aws:iam::497558676238:role/LabRole' \
            -var='db_username=root' \
            -var='db_password=petclinic'
```

Or using a .tfvars file:

```bash
terraform plan -var-file="variables.tfvars"
terraform apply -var-file="variables.tfvars" -auto-approve
```

## Network

The infrastructure consists of a single VPC with CIDR block of **10.0.0.0/16**, divided into two Availability Zones (AZ), each one hosting a subnet.

The VPC's CIDR block is divided in two halfs. The first half **10.0.0.0/17** is used for public subnets, and the second half **10.0.128.0/17** for private subnets.

Each half of the CIDR block is further divided among the number of subnets, two public and two private. The public ones having the blocks **10.0.0.0/18** and **10.0.64.0/18**, and the private ones having **10.0.128.0/19**, **10.0.160.0/19**, **10.0.192.0/19** and **10.0.224.0/19**.

This segregation of public and private networks gives more control over network traffic. It allows the implementation of different routing rules and policies for each network range.

## Terraform Modules

This repo uses some of the AWS official modules:

- [terraform-aws-modules/vpc/aws](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest)
- [terraform-aws-modules/security-group/aws](https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/latest)
- [terraform-aws-modules/ec2-instance/aws](https://registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws/latest)
- [terraform-aws-modules/eks/aws](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/19.1.0)

As well as custom ones, currently under the **modules** folder:

- [RDS](./src/modules/rds/main.tf)
- [Aurora](./src/modules/aurora/main.tf)
- [EKS](./src/modules/eks/main.tf)
