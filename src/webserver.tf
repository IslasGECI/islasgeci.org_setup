resource "azurerm_resource_group" "webserver" {
  name     = "webserver-resources"
  location = "West US 2"
}

resource "azurerm_virtual_network" "webserver" {
  name                = "webserver-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.webserver.location
  resource_group_name = azurerm_resource_group.webserver.name
}

resource "azurerm_subnet" "webserver" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.webserver.name
  virtual_network_name = azurerm_virtual_network.webserver.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "webserver" {
  name                = "webserver-public-ip"
  location            = azurerm_resource_group.webserver.location
  resource_group_name = azurerm_resource_group.webserver.name
  allocation_method   = "Static"
}

resource "azurerm_network_security_group" "webserver" {
  name                = "webserver-nsg"
  location            = azurerm_resource_group.webserver.location
  resource_group_name = azurerm_resource_group.webserver.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 90
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

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
    name                       = "AllowPort100"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "100"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowPort200"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "200"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowPort300"
    priority                   = 140
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "300"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowPort500"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "500"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "webserver" {
  name                      = "webserver-nic"
  location                  = azurerm_resource_group.webserver.location
  resource_group_name       = azurerm_resource_group.webserver.name
  network_security_group_id = azurerm_network_security_group.webserver.id

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.webserver.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.webserver.id
  }
}

resource "azurerm_linux_virtual_machine" "webserver" {
  name                = "webserver"
  resource_group_name = azurerm_resource_group.webserver.name
  location            = azurerm_resource_group.webserver.location
  size                = "Standard_B2s"
  admin_username      = "ciencia_datos"
  network_interface_ids = [
    azurerm_network_interface.webserver.id,
  ]

  admin_ssh_key {
    username   = "ciencia_datos"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 64
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
}

data "azurerm_public_ip" "webserver" {
  name                = azurerm_public_ip.webserver.name
  resource_group_name = azurerm_linux_virtual_machine.webserver.resource_group_name
}

output "webserver_ip" {
  value = data.azurerm_public_ip.webserver.ip_address
}
