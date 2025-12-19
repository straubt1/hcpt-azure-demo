locals {
  vm_count = 2
}

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
  count               = local.vm_count
  name                = "pip-vm-rhel9-${count.index}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Network Interface
resource "azurerm_network_interface" "vm" {
  count               = local.vm_count
  name                = "nic-vm-rhel9-${count.index}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.public.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm[count.index].id
  }
}

# Associate NSG with Network Interface
resource "azurerm_network_interface_security_group_association" "vm" {
  count                     = local.vm_count
  network_interface_id      = azurerm_network_interface.vm[count.index].id
  network_security_group_id = azurerm_network_security_group.vm.id
}

# Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "rhel9" {
  count               = local.vm_count
  name                = "vm-rhel9-${count.index}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size                = "Standard_D2s_v3"
  admin_username      = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.vm[count.index].id,
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

  custom_data = base64encode(file("${path.module}/scripts/cloud-init.sh"))

  # lifecycle {
  #   action_trigger {
  #     events  = [after_create]
  #     actions = [action.aap_job_launch.test]
  #   }
  # }
}


# provider "aap" {
#   host  = "https://myaap.example.com"
#   token = "aap-token"
# }

# # Define an action to send a payload to AAP API.
# action "aap_job_launch" "test" {
#   config {
#     job_template_id     = 1234
#     wait_for_completion = true
#   }
# }
