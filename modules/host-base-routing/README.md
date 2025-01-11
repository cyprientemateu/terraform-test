# AWS Infrastructure POC with Terraform

## Overview
This project demonstrates the use of Terraform to provision secure and scalable AWS infrastructure. The setup includes resources for load balancing, securing traffic, and efficient DNS management.

## Prerequisites
You need to have you aws account setup, your ACM certificate, domain and hosted zone ready. In case you have no ACM ready, I do have the terraform code for ACM certificate creation ready within this repository.

- here's the link to acm code block:

[Navigate to the project directory:](https://github.com/cyprientemateu/terraform-test.git/resources/acm)

### Key Components:

1. AWS Certificate Manager (ACM):

    - Used to provision and manage an SSL certificate for securing the domain.

2. Elastic Load Balancer (ELB):

    - Distributes incoming traffic across EC2 instances to ensure high availability and prevent overloading a single instance.

3. Target Group:

    - Ensures that traffic is routed to healthy instances based on configured health checks.

4. Amazon Route 53:

    - Configures DNS records to direct traffic to the load balancer and supports secure domain routing.

5. EC2 Instances:

    - Hosts the application, providing compute resources within the architecture.

6. Terraform (IaC):

    - Automates the creation and management of all AWS resources in the POC.

## Workflow

+ Step 1: Terraform provisions the AWS infrastructure, including the ACM certificate, ELB, target group, EC2 instances, and DNS records in Route 53.
 
+ Step 2: The Elastic Load Balancer manages incoming traffic, distributing it to the EC2 instances based on the health checks defined in the target group.

+ Step 3: The ACM certificate ensures all traffic to the domain is encrypted, securing communication.

+ Step 4: Route 53 resolves the domain name and directs traffic to the load balancer.
 
## Features
- Scalable and Secure: The infrastructure can handle varying traffic loads while ensuring secure communication.

- Automated Deployment: Terraform eliminates manual setup, ensuring reproducibility and efficiency.

- High Availability: The load balancer prevents a single point of failure.

## Getting Started

1. Clone the repository:

```bash
git clone https://github.com/cyprientemateu/terraform-test.git
```

2. Navigate to the project directory:

```bash
cd modules/host-base-routing
```
2. Initialize Terraform:

```bash
terraform init
```
3. Apply the configuration:

```bash
terraform apply
```
 #### Note: Review and confirm the changes before applying.

 5. Access the application using the domain secured with the ACM certificate.

## Image Gallery

- Here’s how the infrastructure looks:

## Screenshots

### ALB
![alb screenshot](modules/host-base-routing/images/alb.png)

### Blue Instance
![Blue instace app screenshot](modules/host-base-routing/images/blue-instance-app.png)

### Green Instance
![Green instance app screenshot](modules/host-base-routing/images/green-instance-app.png)

### Yellow Instance
![Yellow instance app screenshot](modules/host-base-routing/images/yellow-instance-app.png)

### Certificate
![Green instance app screenshot](modules/host-base-routing/images/certificate.png)

### DNS 
![DNS screenshot](modules/host-base-routing/images/dns-configuration.png)

### Instances
![Instances screenshot](modules/host-base-routing/images/instances.png)

### Running Instances
![Running instances screenshot](modules/host-base-routing/images/running-instances.png)

### Target Groups
![Target Groups screenshot](modules/host-base-routing/images/target-groups.png)

### terraform
![Terraform code screenshot](modules/host-base-routing/images/terraform.png)

## Future Improvements
- Automate monitoring and alerts using CloudWatch or other tools.
- Add auto-scaling groups for EC2 instances to handle dynamic traffic.