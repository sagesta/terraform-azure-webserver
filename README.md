# Terraform Azure Web Server

## Prerequisites

- Terraform (>= 1.7.0)
- Azure CLI
- Azure Subscription

## Setup Instructions

1. Clone the repository
2. Create a `terraform.tfvars` file with the following contents:

```hcl
region         = "West Europe"
vm_size        = "Standard_B1s"
name_prefix    = "miniweb"
my_ip          = "YOUR_IP_ADDRESS/32"  # Replace with your actual IP
ssh_public_key = "YOUR_SSH_PUBLIC_KEY"  # Replace with your actual SSH public key
```

3. Initialize Terraform:
```bash
terraform init
```

4. Validate the configuration:
```bash
terraform fmt
terraform validate
```

5. Plan and apply:
```bash
terraform plan
terraform apply
```

## Important Security Notes

- Never commit `terraform.tfvars` to version control
- Keep your SSH keys and IP addresses private
- Destroy resources when not in use to avoid unnecessary charges

## Cleanup

To destroy the infrastructure:

```bash
terraform destroy
```

## Required Providers

- Azure Provider: hashicorp/azurerm ~> 4.27
- Terraform Core: >= 1.7
