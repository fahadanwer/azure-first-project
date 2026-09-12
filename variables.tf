
# Define variables here

# Variable: A variable is an input to your Terraform configuration.

variable "resource_group_name" {
  description = "The name of the Azure Resource Group"
  type        = string
  default     = "terraform-learning-rg"
}

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "australiaeast"
}


variable "storage_account_name" {
  description = "The name of the Azure Storage Account"
  type        = string
}