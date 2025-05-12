terraform {
  required_version = ">= 1.7.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.27"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "web_rg" {
  name     = "${var.name_prefix}-rg"
  location = var.region
}

# Create a virtual network
resource "azurerm_virtual_network" "web_vnet" {
  name                = "${var.name_prefix}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.web_rg.location
  resource_group_name = azurerm_resource_group.web_rg.name
}

# Create a subnet
resource "azurerm_subnet" "web_subnet" {
  name                 = "${var.name_prefix}-subnet"
  resource_group_name  = azurerm_resource_group.web_rg.name
  virtual_network_name = azurerm_virtual_network.web_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a public IP
resource "azurerm_public_ip" "web_ip" {
  name                = "${var.name_prefix}-public-ip"
  location            = azurerm_resource_group.web_rg.location
  resource_group_name = azurerm_resource_group.web_rg.name
  allocation_method   = "Static"  # Changed from "Dynamic" to "Static"
  sku                 = "Standard"
}

# Create a Network Security Group with rules
resource "azurerm_network_security_group" "web_nsg" {
  name                = "${var.name_prefix}-nsg"
  location            = azurerm_resource_group.web_rg.location
  resource_group_name = azurerm_resource_group.web_rg.name

  # Allow SSH from your IP only
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.my_ip
    destination_address_prefix = "*"
  }

  # Allow HTTP traffic from anywhere
  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create a network interface
resource "azurerm_network_interface" "web_nic" {
  name                = "${var.name_prefix}-nic"
  location            = azurerm_resource_group.web_rg.location
  resource_group_name = azurerm_resource_group.web_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.web_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.web_ip.id
  }
}

# Connect the network interface to the NSG
resource "azurerm_network_interface_security_group_association" "web_nic_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.web_nic.id
  network_security_group_id = azurerm_network_security_group.web_nsg.id
}

# Create a Linux virtual machine
resource "azurerm_linux_virtual_machine" "web_vm" {
  name                  = "${var.name_prefix}-vm"
  location              = azurerm_resource_group.web_rg.location
  resource_group_name   = azurerm_resource_group.web_rg.name
  size                  = var.vm_size
  admin_username        = "adminuser"
  network_interface_ids = [azurerm_network_interface.web_nic.id]

  admin_ssh_key {
    username   = "adminuser"
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  custom_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    
    # Create a styled Hello Terraform page
    cat > /var/www/html/index.html << 'HTMLCONTENT'
    <!DOCTYPE html>
    <html>
    <head>
      <title>Hello Terraform</title>
      <style>
        body {
          font-family: Arial, sans-serif;
          background-color: #f0f0f0;
          margin: 0;
          padding: 0;
          display: flex;
          justify-content: center;
          align-items: center;
          height: 100vh;
          text-align: center;
        }
        .container {
          background-color: white;
          border-radius: 8px;
          box-shadow: 0 4px 8px rgba(0,0,0,0.1);
          padding: 40px;
          max-width: 600px;
        }
        h1 {
          color: #336699;
          font-size: 2.5em;
          margin-bottom: 10px;
        }
        p {
          color: #555;
          font-size: 1.2em;
          margin: 20px 0;
        }
        .highlight {
          font-weight: bold;
          background-color: #e6f7ff;
          padding: 5px 10px;
          border-radius: 4px;
        }
      </style>
    </head>
    <body>
      <div class="container">
        <h1>Hello Terraform!</h1>
        <p>This page is served by <span class="highlight">Samuel Adebodun</span> on a Linux VM</p>
        <p>Created with Infrastructure as Code</p>
        <p>Running on Azure</p>
      </div>
    </body>
    </html>
    HTMLCONTENT
    
    systemctl enable nginx
    systemctl restart nginx
  EOF
  )
}