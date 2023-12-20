# Resource group creation
resource "azurerm_resource_group" "rg" {
  name     = var.fw_rg_name
  location = "westeurope"
}

#VNET creation
resource "azurerm_virtual_network" "my_terraform_network" {
  name                = "${var.fw_vnet_name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create managemnet subnet
resource "azurerm_subnet" "my_terraform_mgmt_subnet" {
  name                 = "${var.fw_mgmt_subnet_name}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.my_terraform_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create trust subnet
resource "azurerm_subnet" "my_terraform_trust_subnet" {
  name                 = "${var.fw_trust_subnet_name}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.my_terraform_network.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create untrust subnet
resource "azurerm_subnet" "my_terraform_untrust_subnet" {
  name                 = "${var.fw_untrust_subnet_name}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.my_terraform_network.name
  address_prefixes     = ["10.0.3.0/24"]
}

# Create mgmt NSG
resource "azurerm_network_security_group" "mgmt_nsg" {
  name                = "FW-MGMT-NSG"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# ------ Inbound Rules------
 resource "azurerm_network_security_rule" "mgmt" {
   name                        = "Allow-mgmt-Inbound"
   resource_group_name         = azurerm_resource_group.rg.name
   network_security_group_name = azurerm_network_security_group.mgmt_nsg.name
   priority                    = 110
   direction                   = "Inbound"
   access                      = "Allow"
   protocol                    = "Tcp"
   source_port_range           = "*"
   destination_port_ranges     = ["80","443","22","3389"]
   source_address_prefix       = "*"
   destination_address_prefix  = "*"
   description                 = "allow mgmt inbound"
 }

#Associate mgmt NSG and Subnet
resource "azurerm_subnet_network_security_group_association" "mgt_nsg_assoc" {
  subnet_id                 = azurerm_subnet.my_terraform_mgmt_subnet.id
  network_security_group_id = azurerm_network_security_group.mgmt_nsg.id
}
 
 resource "azurerm_network_security_group" "trust_nsg" {
  name                = "FW-TRUST-NSG"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}
# ------ Inbound Rules------

 resource "azurerm_network_security_rule" "trust" {
   name                        = "Allow-all-Inbound"
   resource_group_name         = azurerm_resource_group.rg.name
   network_security_group_name = azurerm_network_security_group.trust_nsg.name
   priority                    = 110
   direction                   = "Inbound"
   access                      = "Allow"
   protocol                    = "*"
   source_port_range           = "*"
   destination_port_range      = "*"
   source_address_prefix       = "*"
   destination_address_prefix  = "*"
   description                 = "allow all inbound"
 }

# Outbound rules
 resource "azurerm_network_security_rule" "trust-out" {
   name                        = "Allow-all-Outbound"
   resource_group_name         = azurerm_resource_group.rg.name
   network_security_group_name = azurerm_network_security_group.trust_nsg.name
   priority                    = 110
   direction                   = "Outbound"
   access                      = "Allow"
   protocol                    = "*"
   source_port_range           = "*"
   destination_port_range      = "*"
   source_address_prefix       = "*"
   destination_address_prefix  = "*"
   description                 = "allow all Outbound"
 }
 
 #Associate NSG and Subnet
resource "azurerm_subnet_network_security_group_association" "trust_nsg_assoc" {
  subnet_id                 = azurerm_subnet.my_terraform_trust_subnet.id
  network_security_group_id = azurerm_network_security_group.trust_nsg.id
}
 
 resource "azurerm_network_security_group" "untrust_nsg" {
  name                = "FW-UNTRUST-NSG"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}


# ------ Inbound Rules------

 resource "azurerm_network_security_rule" "Untrust_in" {
   name                        = "Allow-all-Inbound"
   resource_group_name         = azurerm_resource_group.rg.name
   network_security_group_name = azurerm_network_security_group.untrust_nsg.name
   priority                    = 110
   direction                   = "Inbound"
   access                      = "Allow"
   protocol                    = "*"
   source_port_range           = "*"
   destination_port_range      = "*"
   source_address_prefix       = "*"
   destination_address_prefix  = "*"
   description                 = "allow all inbound"
 }

 resource "azurerm_network_security_rule" "untrust_out" {
   name                        = "Allow-all-Outbound"
   resource_group_name         = azurerm_resource_group.rg.name
   network_security_group_name = azurerm_network_security_group.untrust_nsg.name
   priority                    = 110
   direction                   = "Outbound"
   access                      = "Allow"
   protocol                    = "*"
   source_port_range           = "*"
   destination_port_range      = "*"
   source_address_prefix       = "*"
   destination_address_prefix  = "*"
   description                 = "allow all Outbound"
 }
 
 #Associate NSG and Subnet
resource "azurerm_subnet_network_security_group_association" "untrust_nsg_assoc" {
  subnet_id                 = azurerm_subnet.my_terraform_untrust_subnet.id
  network_security_group_id = azurerm_network_security_group.untrust_nsg.id
}

resource "azurerm_public_ip" "mgmt_public" {
  name = "Mgmt_public_IP"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method = "Dynamic"
}

resource "azurerm_public_ip" "untrust_public" {
  name = "Untrust_public_IP"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method = "Dynamic"
}

resource "azurerm_network_interface" "mgmt_nic" {
  name                = "FW_mgmt_nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  depends_on          = ["azurerm_virtual_network.my_terraform_network",
                          "azurerm_public_ip.mgmt_public"]

  ip_configuration {
    name                          = "Fw_mgmt_private_IP"
    subnet_id                     = azurerm_subnet.my_terraform_mgmt_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.mgmt_public.id
  }
}

resource "azurerm_network_interface" "trust_nic" {
  name                = "FW_trust_nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  depends_on          = ["azurerm_virtual_network.my_terraform_network"]
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "FW_Trust_IP"
    subnet_id                     = azurerm_subnet.my_terraform_trust_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_network_interface" "untrust_nic" {
  name                = "FW_untrust_nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  depends_on          = ["azurerm_virtual_network.my_terraform_network",
                          "azurerm_public_ip.untrust_public"]
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "FW_Untrust_IP"
    subnet_id                     = azurerm_subnet.my_terraform_untrust_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.untrust_public.id
  }
}
  
  # Configure PAN FW VMs
resource "azurerm_virtual_machine" "fw02VirtualMachine" {
  name                             = "Palo-fw"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  vm_size                          = "Standard_DS3_v2"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  plan {
    name      = "bundle2"
    publisher = "paloaltonetworks"
    product   = "vmseries1"
  }

  storage_image_reference {
    publisher = "paloaltonetworks"
    offer     = "vmseries1"
    sku       = "bundle2"
    version   = "latest"
  }

  storage_os_disk {
    name              = "PAN-FW_STorage-060991"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    disk_size_gb      = "256"
    managed_disk_type = "Premium_LRS"
  }

  os_profile {
    computer_name  = "PA-FW"
    admin_username = "admin-user"
    admin_password = "password@123"
}

  primary_network_interface_id = azurerm_network_interface.mgmt_nic.id
  network_interface_ids = [azurerm_network_interface.mgmt_nic.id,
                           azurerm_network_interface.trust_nic.id,
                           azurerm_network_interface.untrust_nic.id,
                          ]

  os_profile_linux_config {
    disable_password_authentication = false
  }
}
