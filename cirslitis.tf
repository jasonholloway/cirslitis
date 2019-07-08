
variable "name" {
	type = "string"
}

variable "rg" {
	default = "cirslis"
}

variable "loc" {
	default = "northeurope"
}

variable "storage" {
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
  name = "${var.name}.vhd"
	source = "${path.module}/out/${var.name}.vhd"
  type = "page"

  storage_container_name = "vhds"
  resource_group_name    = "${var.rg}"
  storage_account_name   = "${var.storage}"
}



resource "azurerm_virtual_machine" "vm" {
  name                  = "${var.name}-vm"
  resource_group_name   = "${var.rg}"
	location = "${var.loc}"

  network_interface_ids = ["${azurerm_network_interface.nic.id}"]
  vm_size               = "Standard_B1ls"

  storage_os_disk {
    name = "osdisk"
    create_option = "attach"
		os_type = "linux"
		vhd_uri = "${azurerm_storage_blob.vhd.url}"
  }
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.name}-nic"
  resource_group_name = "${var.rg}"
	location = "${var.loc}"

	network_security_group_id = "${azurerm_network_security_group.nsg.id}"

  ip_configuration {
    name                          = "ip1"
    subnet_id                     = "${var.subnet}"
    private_ip_address_allocation = "Dynamic"
    # public_ip_address_id          = "${var.public_ip}"
  }
}

resource "azurerm_network_security_group" "nsg" {
    name                = "${var.name}-nsg"
    resource_group_name = "${var.rg}"
    location            = "${var.loc}"
    
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
}
