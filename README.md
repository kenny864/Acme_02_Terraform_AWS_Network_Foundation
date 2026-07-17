# Acme 02 Terraform AWS Network Foundation

## Overview

This project provisions the foundational AWS networking infrastructure for **Acme Analytics**, a fictional SaaS startup. Before applications can be deployed, the company requires a secure, highly available Virtual Private Cloud (VPC) that follows AWS networking best practices.

Using **Terraform**, this project creates a production-ready VPC spanning two Availability Zones with public and private subnets, Internet and NAT Gateways, route tables, and security groups. The infrastructure is designed to support future application deployments while keeping backend services isolated from the public Internet.

---

## Business Scenario

Acme Analytics is preparing to launch its first customer-facing application.

The cloud engineering team has been tasked with building the organization's AWS networking foundation. The infrastructure must:

* Support high availability
* Isolate public and private resources
* Secure backend services
* Be reusable through Infrastructure as Code
* Support future expansion

This project represents the first production network for the company.

---

## Features

* Creates a custom VPC
* Deploys resources across two Availability Zones
* Creates public subnets
* Creates private application subnets
* Creates private database subnets
* Creates an Internet Gateway
* Creates a NAT Gateway with Elastic IP
* Configures route tables and associations
* Creates security groups for future applications
* Outputs important networking information

---

## AWS Architecture

Resources created include:

* Amazon VPC
* Public Subnets
* Private Application Subnets
* Private Database Subnets
* Internet Gateway
* NAT Gateway
* Elastic IP
* Route Tables
* Route Table Associations
* Security Groups

Traffic Flow

Internet

↓

Application Load Balancer

↓

Application Servers

↓

Database

---

## Project Structure

```text
├── main.tf
├── providers.tf
├── state.tf
└── README.md
```

---

## How It Works

Terraform performs the following steps:

1. Creates the VPC.
2. Creates six subnets across two Availability Zones (regardless of Region).
3. Attaches an Internet Gateway.
4. Allocates an Elastic IP.
5. Creates a NAT Gateway.
6. Creates public and private route tables.
7. Associates route tables with the correct subnets.
8. Creates security groups for future infrastructure.
9. Outputs networking resource IDs.

---

## Prerequisites

* AWS Account
* Terraform 1.x
* AWS CLI configured
* IAM permissions for:

  * VPC
  * EC2
  * Elastic IP
  * NAT Gateway
  * Route Tables
  * Security Groups

---

## Usage

Initialize Terraform

```bash
terraform init
```

Review the deployment

```bash
terraform plan
```

Deploy the infrastructure

```bash
terraform apply
```

Destroy the infrastructure

```bash
terraform destroy
```

---

## Skills Demonstrated

* Terraform
* Infrastructure as Code
* AWS VPC
* Subnet Design
* High Availability
* Route Tables
* Internet Gateway
* NAT Gateway
* Elastic IP
* Security Groups
* CIDR Planning

---

## Security Considerations

This project follows AWS networking best practices by:

* Separating public and private workloads
* Keeping databases in private subnets
* Restricting traffic through Security Groups
* Preparing infrastructure for least-privilege access

---

## Future Improvements

* VPC Flow Logs
* Network ACL customization
* IPv6 support
* Transit Gateway integration
* VPC Endpoints
* AWS Network Firewall

---

## Learning Objectives

* Build a production-ready AWS network
* Understand VPC design
* Learn subnet architecture
* Configure secure routing
* Deploy reusable networking infrastructure with Terraform

---

## Screenshots

Recommended screenshots:

* terraform plan
* terraform apply
* AWS VPC Dashboard
* Subnets
* Route Tables
* NAT Gateway
* Security Groups

---

## Author

**Kenny Jean-Baptiste**

This project is part of the **Acme Analytics Terraform Portfolio**, demonstrating production-oriented AWS infrastructure built with Infrastructure as Code.

---

## License

This project is licensed under the MIT License.