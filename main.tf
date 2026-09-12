
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}

  resource_provider_registrations = "none"

}


resource "azurerm_resource_group" "learning" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    environment = "learning"
    managed_by  = "terraform"
  }
}


resource "azurerm_storage_account" "learning" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.learning.name
  location                 = azurerm_resource_group.learning.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "learning"
    managed_by  = "terraform"
  }
}


resource "azurerm_virtual_network" "learning" {
  name                = "tf-learning-vnet"
  resource_group_name = azurerm_resource_group.learning.name #IMP:this is how terraform knows that resource group needs to exist before the VNet can be created. This is an implicit dependency.
  location            = azurerm_resource_group.learning.location
  address_space       = ["10.0.0.0/16"] # this is a list

  tags = {
    environment = "learning"
    managed_by  = "terraform"
  }
}


resource "azurerm_subnet" "learning" {
  name                 = "tf-learning-subnet"
  resource_group_name  = azurerm_resource_group.learning.name
  virtual_network_name = azurerm_virtual_network.learning.name
  address_prefixes     = ["10.0.1.0/24"]
}



resource "azurerm_network_security_group" "learning" { #Terraform's internal name is: azurerm_network_security_group.learning
  name                = "tf-learning-nsg"              # Azure's actual name will be: tf-learning-nsg
  location            = azurerm_resource_group.learning.location
  resource_group_name = azurerm_resource_group.learning.name

  tags = {
    environment = "learning"
    managed_by  = "terraform"
  }
}




resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "Allow-SSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.learning.name
  network_security_group_name = azurerm_network_security_group.learning.name
}



resource "azurerm_network_security_rule" "allow_http" {
  name                        = "Allow-HTTP"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.learning.name
  network_security_group_name = azurerm_network_security_group.learning.name
}



resource "azurerm_network_security_rule" "allow_https" {
  name                        = "Allow-HTTPS"
  priority                    = 300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.learning.name
  network_security_group_name = azurerm_network_security_group.learning.name
}



# NSG-to-Subnet association: Creating relationship between two resources

resource "azurerm_subnet_network_security_group_association" "learning" {
  subnet_id                 = azurerm_subnet.learning.id
  network_security_group_id = azurerm_network_security_group.learning.id
}




# creating Standartd Public IP address # IP address = 20.58.144.238

resource "azurerm_public_ip" "learning" {
  name                = "tf-learning-public-ip"
  location            = azurerm_resource_group.learning.location
  resource_group_name = azurerm_resource_group.learning.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    environment = "learning"
    managed_by  = "terraform"
  }
}



# creating NIC and associating Public IP and Subnet with it

resource "azurerm_network_interface" "learning" {
  name                = "tf-learning-nic"
  location            = azurerm_resource_group.learning.location
  resource_group_name = azurerm_resource_group.learning.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.learning.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.learning.id
  }

  tags = {
    environment = "learning"
    managed_by  = "terraform"
  }
}




# creating Ubuntu VM and providing SSH public key to place in VM 

resource "azurerm_linux_virtual_machine" "learning" {
  name                = "tf-learning-vm"
  resource_group_name = azurerm_resource_group.learning.name
  location            = azurerm_resource_group.learning.location
  size                = "Standard_B2ats_v2"
  admin_username      = "azureuser"

  network_interface_ids = [ # VM connects to NIC, and the NIC is already connected to subnet. Terraform will build the dependency chain
    azurerm_network_interface.learning.id
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  tags = {
    environment = "learning"
    managed_by  = "terraform"
  }
}





