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
![resource creation](https://github.com/user-attachments/assets/7b056236-855b-4add-99c5-7a392f792547)

```


![resources created](https://github.com/user-attachments/assets/9c2a19c1-ad1b-49d3-b1c5-e09b5a6f47ef)


![running nginx server](https://github.com/user-attachments/assets/21c7f322-fa22-4110-a3f5-d726d68c0e21)

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
