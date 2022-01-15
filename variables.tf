# Module Inputs
variable  "machine_name_prefix" {
  description = "The prefix of the machine name of the machine to be created"
  type        = string
  default     = "test"
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "tags" {
  description = "Resource tags"
  type        = map
}

variable "custom_data" {
  description = "Custom data"
  default    = ""
  type        = string
}

variable "user_data" {
  description = "User data"
  default    = ""
  type        = string
}

# VM Size
variable "virtual_machine_size" {
  description = "Instance size to be provisioned"
  type        = string
}

# Custom Machine Image
variable "custom_image_id" {
  description = "Custom machine image ID"
  type        = string
  default     = null
}

# Operating System
variable "source_image_publisher" {
  description = "Operating System Publisher"
  type        = string
  default     = null
}

variable "source_image_offer" {
  description = "Operating System Name"
  type        = string
  default     = null
}

variable "source_image_sku" {
  description = "Operating System SKU"
  type        = string
  default     = null
}

variable "source_image_version" {
  description = "Operating System Version"
  type        = string
  default     = "latest"
}

# Operating System Disk
variable "operating_system_disk_cache" {
  description = "Type of caching to use on the OS disk - Options: None, ReadOnly or ReadWrite"
  type        = string
  default     = "ReadWrite"
}

variable "operating_system_disk_type" {
  description = "Type of storage account to use with the OS disk - Options: Standard_LRS, StandardSSD_LRS or Premium_LRS"
  type        = string
  default     = "StandardSSD_LRS"
}

variable "operating_system_disk_write_accelerator" {
  description = "Should Write Accelerator be Enabled for this OS Disk?"
  type        = bool
  default     = false
}

# Credentials
variable "admin_username" {
  description = "Default Username"
  type        = string
  default     = "drok"
}

variable "admin_password" {
  description = "Default Password - Random if left blank"
  type        = string
  default     = ""
  sensitive   = true
}

variable "admin_ssh_key" {
  description = "Private SSH key"
  type        = string
  default     = ""
  sensitive   = true
}

# Index
variable "machine_count" {
  description = "Unique Identifier/Count - Random if left at 0"
  type        = number
  default     = 0
}

# Networking
variable "subnet_id" {
  description = "Virtual network subnet ID"
  type        = string
}

variable "public_ip_enabled" {
  description = "Create and attach a public interface?"
  type        = bool
  default     = false
}

variable "public_ip_sku" {
  description = "SKU to be used with this public IP - Basic or Standard"
  type        = string
  default     = "Standard"
}

variable "network_sec_group_id" {
  description = "Network Security Group ID"
  type        = string
  default    = "" 
}