
# A local is a named value that Terraform calculates or stores inside your configuration so you can reuse it in multiple places.

# Local: A local is a value defined inside your Terraform configuration.

locals {

  environment = "learning"
  project     = "terraform-azure"
  managed_by  = "terraform"


  environments = { # this is called map, its key:value data type. Similar to dictionary in python
    dev     = "Development"
    staging = "Staging"
    prod    = "Production"

  }
}

/*
output "environments" {
  value = local.environments
}

OUTPUT:
environments = { 
    dev     = "Development"
    staging = "Staging"
    prod    = "Production"
}






output "environment_names" {
  value = [
    for environment, description in local.environments :
    environment
  ]
}

OUTPUT:
environment_names = [
    dev,
    prod,
    staging,
]








output "environment_values" {
    value = [
        for environment, description in local.environments :
        description
    ]

}

OUTPUT:

environment_values = [
    Development,
    Production,
    Staging
]

*/