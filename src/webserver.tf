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
  domain_name_label   = "webserver"
  location            = azurerm_resource_group.webserver.location
  resource_group_name = azurerm_resource_group.webserver.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "webserver" {
  name                = "webserver-nic"
  location            = azurerm_resource_group.webserver.location
  resource_group_name = azurerm_resource_group.webserver.name

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
  size                = "Standard_D2as_v4"
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
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
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
