
variable "image_name" {
	type = "string"
}

variable "resource_group" {
	default = "cirslis"
}

variable "location" {
	default = "northeurope"
}

variable "storage_account" {
	default = "cirslisdata"
}

variable "subnet" {
	default = "/subscriptions/f6ee1fe9-14a5-49e6-966b-eccf335c6b69/resourceGroups/cirslis/providers/Microsoft.Network/virtualNetworks/cirslis-vnet/subnets/default"
}

variable "public_ip" {
	default = "/subscriptions/f6ee1fe9-14a5-49e6-966b-eccf335c6b69/resourceGroups/cirslis/providers/Microsoft.Network/publicIPAddresses/cirslitis-ip"
}



provider "azurerm" {
	version = "=1.28.0"
}


resource "azurerm_storage_blob" "vhd" {
  name = "${var.image_name}"
	source = "${path.module}/out/${var.image_name}"
  type = "page"

  storage_container_name = "vhds"
  resource_group_name    = "${var.resource_group}"
  storage_account_name   = "${var.storage_account}"
}



resource "azurerm_virtual_machine" "vm" {
  name                  = "cirslitis-vm"
  resource_group_name   = "${var.resource_group}"
	location = "${var.location}"

  network_interface_ids = ["${azurerm_network_interface.nic.id}"]
  vm_size               = "Standard_B1ls"

  storage_os_disk {
    name = "osdisk"
		os_type = "Linux"
		vhd_uri = "${azurerm_storage_blob.vhd.url}"
    create_option = "Attach"
  }
}

resource "azurerm_network_interface" "nic" {
  name                = "cirslitis-nic"
  resource_group_name = "${var.resource_group}"
	location = "${var.location}"

	network_security_group_id = "${azurerm_network_security_group.nsg.id}"

  ip_configuration {
    name                          = "ip1"
    subnet_id                     = "${var.subnet}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${var.public_ip}"
  }
}

resource "azurerm_network_security_group" "nsg" {
    name                = "cirslitis-nsg"
    resource_group_name = "${var.resource_group}"
    location            = "${var.location}"
    
    security_rule {
        name                       = "fortinet"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "ssh"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}
