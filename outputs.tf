
# Terraform takes information from the resource it has created and now manages and display it as an output.

# format: 

# RESOURCE_TYPE . LOCAL_RESOURCE_NAME . ATTRIBUTE
# azurerm_resource_group.learning.name

# from command line run following commands:
# terraform state list  #first run this to know the name of the azure resource i.e. azurerm_resource_group.learning
# terraform state show <azurerm_resource_group.learning> #This lets you see the whole resource information Terraform has recorded in its state. 







output "resource_group_name" {
  description = "The name of the created Azure Resource Group"
  value       = azurerm_resource_group.learning.name
}

output "resource_group_id" {
  description = "The ID of the created Azure Resource Group"
  value       = azurerm_resource_group.learning.id
}

output "resource_group_location" {
  description = "The location of the created Azure Resource Group"
  value       = azurerm_resource_group.learning.location
}

/*
output "resource_group_tags" {
  description = "The tags of the created Azure Resource Group"
  value       = azurerm_resource_group.learning.tags
}
*/


output "storage_account_name" {
  description = "The name of the created Azure Storage Account"
  value       = azurerm_storage_account.learning.name
}

output "storage_account_id" {
  description = "The ID of the created Azure Storage Account"
  value       = azurerm_storage_account.learning.id
}

output "virtual_network_name" {
  description = "The name of the Azure Virtual Network"
  value       = azurerm_virtual_network.learning.name
}


output "vm_public_ip_address" {
  description = "Public IP address of the virtual machine."
  value       = azurerm_public_ip.learning.ip_address
}



output "project" {
  description = "The project name"
  value       = local.project
}



output "environments" {
  value = local.environments
}



output "environment_names" {
  value = [
    for environment, description in local.environments :
    environment
  ]
}



output "existing_resource_group" {
  description = "Location of the existing resource group"
  value       = data.azurerm_resource_group.existing.location
}