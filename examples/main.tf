terraform {
  required_version = ">= 1.0.11"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 2.90.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "= 3.1.0"
    }
  }
}

provider "azurerm" {
  features {
    // key_vault {
    //   purge_soft_delete_on_destroy = true
    // }
  }
  // use_msi = true

  // backend "azurerm" {
  //   storage_account_name = "sgdrokdevcodeserver"
  //   container_name       = "tfstate"
  //   key                  = "dev.terraform.tfstate"
  //   subscription_id      = "4c521c7d-e9af-4065-bd16-a0fb96cc8439"
  //   tenant_id            = "63a9acfe-dcf3-44c0-a889-e745f794f2c3"
  // }
}

locals  {
    common_tags = {
        environment = var.environment
        admin = var.admin
        security = var.security
        organization = var.organization
        ManagedByTerraform = "true"
    }
  # extra_tags  = {
  #   network = "${var.network1_name}"
  #   support = "${var.network_support_name}"
  # }
}
 
#######
# Resource Groups
#######

resource "azurerm_resource_group" "rg" {
  name      = "rg-${var.environment}-volkmangp"
  location  = var.resource_group_location
  # tags = "${merge( local.common_tags, local.extra_tags)}
  tags = local.common_tags
}

###########
# Key Vault - Add to IaC when the use for key vault is clear
###########

resource "tls_private_key" "ssh" {
    algorithm = "RSA"
    rsa_bits = 4096
}

// resource "azurerm_linux_virtual_machine" "myterraformvm" {
//     computer_name = "myvm"
//     admin_username = "azureuser"
//     disable_password_authentication = true

//     admin_ssh_key {
//         username = "azureuser"
//         public_key = tls_private_key.ssh.public_key_openssh #The magic here
//     }

//     tags = {
//         environment = "Terraform Demo"
//     }
// }


// data "azurerm_client_config" "current" {}

// resource "azurerm_key_vault" "vault" {
//   name                        = "vault-${var.environment}-volkmangp"
//   location                    = azurerm_resource_group.rg.location
//   resource_group_name         = azurerm_resource_group.rg.name
//   enabled_for_disk_encryption = true
//   enabled_for_deployment      = true 
//   enabled_for_template_deployment = true
//   enable_rbac_authorization = true
//   tenant_id                   = data.azurerm_client_config.current.tenant_id
//   soft_delete_retention_days  = 7
//   purge_protection_enabled    = false
//   sku_name = "standard"

//   access_policy {
//     tenant_id = data.azurerm_client_config.current.tenant_id
//     object_id = data.azurerm_client_config.current.object_id

//     key_permissions = [
//       "Get",
//       "Create",
//       "Delete",
//     ]

//     secret_permissions = [
//       "Get",
//       "Delete",
//     ]

//     certificate_permissions = [
//       "Get",
//       "Create",
//       "Delete",
//     ]
//   }
// }

#######
# Networking
#######

## VNET
resource "azurerm_virtual_network" "vnet" {
  name                = "rg-${var.environment}-volkmangp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
  # dns_servers         = ["10.0.0.4", "10.0.0.5"]

  subnet {
    name           = "mgnt"
    address_prefix = "10.0.0.0/24"
    security_group = azurerm_network_security_group.nsg0.id
  }

  subnet {
    name           = "workload"
    address_prefix = "10.0.1.0/24"
    security_group = azurerm_network_security_group.nsg1.id
    
  }
    
  tags = local.common_tags
}

data "azurerm_subnet" "mgnt" {
  name                 = "mgnt"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
}

data "azurerm_subnet" "workload" {
  name                 = "workload"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
}

############
# Virtual Machines
############


module "linux_virtual_machine" {
  source = "./../../terraform-azure-mods/terraform-azurerm-vm"

  // machine_count       = 1
  machine_name_prefix = "mgnt-${var.environment}-volkmangp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.common_tags

  # admin settings
  admin_username = var.admin_username
  // custom_data    = filebase64("scripts/bootstrap.sh")
  // user_data      = filebase64("scripts/userdata")
  # Instance Size
  virtual_machine_size = "Standard_D2_v3"

  # Operating System Image
  source_image_publisher = "Canonical"
  source_image_offer     = "UbuntuServer"
  source_image_sku       = "18.04-LTS"
  source_image_version   = "latest"

  # Virtual Network
  subnet_id         = data.azurerm_subnet.mgnt.id
  public_ip_enabled = true

}

resource "azurerm_network_interface_security_group_association" "mgnt" {
  network_interface_id = module.linux_virtual_machine.network_interface_id
  network_security_group_id = azurerm_network_security_group.nsg0.id
}

# Outputs
output "id" {
  value = module.linux_virtual_machine.*.virtual_machine_id
}

output "name" {
  value = module.linux_virtual_machine.*.virtual_machine_name
}

output "private_ip" {
  value = module.linux_virtual_machine.virtual_machine_private_ip
}

output "public_ip" {
  value = module.linux_virtual_machine.virtual_machine_public_ip
}

output "admin_username" {
  value = module.linux_virtual_machine.admin_username
}

output "admin_password" {
  value = module.linux_virtual_machine.admin_password
  // sensitive = true
}

resource "local_file" "ssh_private_key_pem" {
  filename          = "${path.module}/id_rsa"
  sensitive_content = module.linux_virtual_machine.automation_account_ssh_private
  file_permission   = "0600"
}

resource "local_file" "ssh_public_key_openssh" {
  filename = "${path.module}/id_rsa.pub"
  content  = module.linux_virtual_machine.automation_account_ssh_public
}