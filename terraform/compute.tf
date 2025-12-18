# Generate SSH key pair
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Data source to lookup RHEL 9 image
data "azurerm_platform_image" "rhel9" {
  location  = azurerm_resource_group.main.location
  publisher = "RedHat"
  offer     = "RHEL"
  sku       = "9-lvm-gen2"
}

# Public IP for the VM
resource "azurerm_public_ip" "vm" {
  name                = "pip-vm-rhel9"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Network Security Group
resource "azurerm_network_security_group" "vm" {
  name                = "nsg-vm-rhel9"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowSSH"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Network Interface
resource "azurerm_network_interface" "vm" {
  name                = "nic-vm-rhel9"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.public.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm.id
  }
}

# Associate NSG with Network Interface
resource "azurerm_network_interface_security_group_association" "vm" {
  network_interface_id      = azurerm_network_interface.vm.id
  network_security_group_id = azurerm_network_security_group.vm.id
}

# Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "rhel9" {
  count               = 1
  name                = "vm-rhel9-${count.index}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size                = "Standard_D2s_v3"
  admin_username      = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.vm.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.ssh.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = data.azurerm_platform_image.rhel9.publisher
    offer     = data.azurerm_platform_image.rhel9.offer
    sku       = data.azurerm_platform_image.rhel9.sku
    version   = "latest"
  }

  # lifecycle {
  #   action_trigger {
  #     events  = [after_create]
  #     actions = [action.aap_job_launch.test]
  #   }
  # }

  custom_data = base64encode(<<-EOF
    #!/bin/bash
    # Install Apache web server
    dnf install -y httpd
    
    # Create a simple HTML page
    cat > /var/www/html/index.html <<'HTML'
    <!DOCTYPE html>
    <html>
    <head>
        <title>RHEL 9 VM on Azure</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 50px;
                background-color: #f0f0f0;
            }
            .container {
                background-color: white;
                padding: 30px;
                border-radius: 10px;
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            }
            h1 { color: #0078D4; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>Welcome to RHEL 9 on Azure!</h1>
            <p>This web server was automatically created and configured using Terraform!</p>
        </div>
    </body>
    </html>
    HTML
    
    # Start and enable Apache
    systemctl start httpd
    systemctl enable httpd
    
    # Open firewall for HTTP
    firewall-cmd --permanent --add-service=http
    firewall-cmd --reload
  EOF
  )
}
