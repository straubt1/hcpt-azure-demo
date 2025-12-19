# hcpt-azure-demo

This project demonstrates how to deploy a RHEL 9 virtual machine on Azure using Terraform. The VM is automatically configured with Apache web server and a simple HTML page using a cloud-init script.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed
- An Azure account

## Usage

1. Clone the repository:

```bash
git clone https://github.com/straubt1/hcpt-azure-demo.git
cd hcpt-azure-demo/terraform
```

1. Initialize Terraform:

```bash
terraform init
```

1. Apply the Terraform configuration:

```bash
terraform apply
```

1. Once the deployment is complete, you can access the web server using the public IP address of the VM.
