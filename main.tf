terraform {
  required_version = ">= 0.13.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.48.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1.0"
    }
  }
}

# Randoms

resource "random_password" "password" {
  length      = 32
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = 1
  special     = true
}

resource "random_integer" "count" {
  min = 01
  max = 99
}

resource "tls_private_key" "automation_account" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Variables
// locals {
//   admin_password = (var.admin_password != "" ? var.admin_password : random_password.password.result)
//   admin_ssh_key  = (var.admin_ssh_key != "" ? var.admin_ssh_key : tls_private_key.automation_account.public_key_openssh)
// }


# Network Interfaces
resource "azurerm_public_ip" "primary" {
  count = var.public_ip_enabled ? var.machine_count : 0

  name                = "${var.machine_name_prefix}-${count.index}-pip"
  // name                = "${var.machine_name_prefix}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  allocation_method = "Static"
  sku               = var.public_ip_sku
}

resource "azurerm_network_interface" "dynamic" {
  count               = var.machine_count
  name                = "${var.machine_name_prefix}-${count.index}-nic"
  // name                = "${var.machine_name_prefix}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(concat(azurerm_public_ip.primary.*.id, tolist([""])), count.index)
    // public_ip_address_id          = azurerm_public_ip.primary.id
  }
}

# Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "linux" {
  count               = var.machine_count
  name                = "${var.machine_name_prefix}-${count.index}"
  // name                = var.machine_name_prefix
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  size                            = var.virtual_machine_size
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = true
  network_interface_ids = [
    element(azurerm_network_interface.dynamic.*.id, count.index),
  ]
  // network_interface_ids = [
  //   azurerm_network_interface.dynamic.id,
  // ]
  source_image_id = var.custom_image_id
  custom_data = var.custom_data
  // user_data   = var.user_data
  dynamic "source_image_reference" {
    for_each = var.custom_image_id == null ? ["no_custom_image_provided"] : []

    content {
      publisher = var.source_image_publisher
      offer     = var.source_image_offer
      sku       = var.source_image_sku
      version   = var.source_image_version
    }
  }

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_key
  }

  os_disk {
    caching                   = var.operating_system_disk_cache
    storage_account_type      = var.operating_system_disk_type
    write_accelerator_enabled = var.operating_system_disk_write_accelerator
  }
}

// resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
//   network_interface_id = element(concat(azurerm_network_interface.dynamic.*.id, [""]), count.index)
  
//   network_security_group_id = var.network_sec_group_id
// }


