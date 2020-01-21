
terraform {
    backend "azurerm" {
    storage_account_name  	= "<unique name od the storage>"
    container_name        	= "tf-container"
    access_key              = "<here is the access key from the Storage>"
    key                   	= "terraform.tfstate"

    }
}

provider "azurerm" {
	# version				="1.38"
	# client_id           = "${var.client_id}"
	# client_secret       = "${var.client_secret}"
	# tenant_id           = "${var.tenant_id}"
	# subscription_id     = "${var.subscription_id}" 

}


resource "azurerm_resource_group" "Dimche_TF_RG" {
    name        = "${var.NameRG}"
    location    = "${var.location}"
    tags = {
    environment = "Terraform Demo"
  }
  
}

resource "azurerm_virtual_network" "Dimche_VNET" {
  name                = "${var.vnet}"
  location            = "${azurerm_resource_group.Dimche_TF_RG.location}"
  resource_group_name = "${azurerm_resource_group.Dimche_TF_RG.name}"
  address_space       = ["10.0.0.0/16"]
}



resource "azurerm_subnet" "Dimche-subnet" {
  name                 = "dimche-subnet"					
  resource_group_name  = "${azurerm_resource_group.Dimche_TF_RG.name}"
  virtual_network_name = "${azurerm_virtual_network.Dimche_VNET.name}"
  address_prefix       = "10.0.2.0/24"
}

# Create public IPs
resource "azurerm_public_ip" "Dimche-terraform-publicip" {
    name                         = "PublicIP"
    location                     = "${var.location}"
    resource_group_name          = "${azurerm_resource_group.Dimche_TF_RG.name}"
    allocation_method            = "Dynamic"

}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "dimche-terraform-nsg" {
    name                = "NetworkSecurityGroup"
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.Dimche_TF_RG.name}"
    
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

}

  resource "azurerm_network_interface" "net_int" {
  name                = "dimche_n_int"
  location            = "${azurerm_resource_group.Dimche_TF_RG.location}"
  resource_group_name = "${azurerm_resource_group.Dimche_TF_RG.name}"
										 
	 

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${azurerm_subnet.Dimche-subnet.id}"
    private_ip_address_allocation = "Dynamic"
		#network_security_group_id     = "${azurerm_network_security_group.dimche-terraform-nsg.id}"					
  }
 }

  resource "azurerm_virtual_machine" "myterraformvm" {
    name                  = "dimche_vm"
    location              = "${azurerm_resource_group.Dimche_TF_RG.location}"
    resource_group_name   = "${azurerm_resource_group.Dimche_TF_RG.name}"
    network_interface_ids = ["${azurerm_network_interface.net_int.id}"]
    vm_size               = "Standard_DS1_v2"
    storage_os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }
    os_profile {
        computer_name  = "dimchevm"
        admin_username = "azuredimche"
		admin_password = "Password1234!"
    }				   
    os_profile_linux_config {
         disable_password_authentication = false
    }
	tags = {
    environment = "Terraform Demo"
  }
}			   

resource "azurerm_virtual_machine_extension" "apache_php" {
  name = "custom_vm_apache"
  location = "${var.location}"
  resource_group_name   = "${azurerm_resource_group.Dimche_TF_RG.name}"
  virtual_machine_name  = "${azurerm_virtual_machine.myterraformvm.name}"
  publisher = "Microsoft.OSTCExtensions"
  #publisher       = "CustomScriptExtension"
  type = "CustomScriptForLinux"
  #type            = "Microsoft.Compute"
  type_handler_version  = "1.5"

  settings = <<SETTINGS
  {
"fileUris": [ "HERE SHOULD BE LINK FROM THE SCRIPT, IN MY CASE LINK FROM THE STOGARE WHERE apache_php_test IS" ] ,
"commandToExecute": "sh apache_php_test.sh"

  }
SETTINGS


}


