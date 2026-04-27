data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

locals {
  common_tags = {
    environment = var.environment
    project     = var.project_name
    managed_by  = "terraform"
  }
}

module "networking" {
  source = "../../modules/networking"

  resource_group_name     = data.azurerm_resource_group.main.name
  location                = data.azurerm_resource_group.main.location
  project_code            = var.project_code
  environment             = var.environment
  vnet_address_space      = var.vnet_address_space
  subnet_address_prefixes = var.subnet_address_prefixes
  tags                    = local.common_tags
}

module "sql" {
  source = "../../modules/sql"

  resource_group_name        = data.azurerm_resource_group.main.name
  location                   = data.azurerm_resource_group.main.location
  sql_server_name            = var.sql_server_name
  sql_database_name          = var.sql_database_name
  sql_admin_username         = var.sql_admin_username
  sql_admin_password         = var.sql_admin_password
  private_endpoint_subnet_id = module.networking.subnet_ids["private_endpoints"]
  vnet_id                    = module.networking.vnet_id
  tags                       = local.common_tags
}

module "keyvault" {
  source = "../../modules/keyvault"

  resource_group_name        = data.azurerm_resource_group.main.name
  location                   = data.azurerm_resource_group.main.location
  key_vault_name             = var.key_vault_name
  tenant_id                  = var.tenant_id
  current_user_object_id     = var.current_user_object_id
  private_endpoint_subnet_id = module.networking.subnet_ids["private_endpoints"]
  vnet_id                    = module.networking.vnet_id
  additional_secret_reader_object_ids = compact([
    module.vm_ops.principal_id
  ])
  tags                       = local.common_tags
}

module "vm_web" {
  source = "../../modules/linux-vm"

  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  vm_name             = "vm-web-${var.project_code}-${var.environment}"
  subnet_id           = module.networking.subnet_ids["web"]
  vm_size             = var.vm_sizes["web"]
  admin_username      = var.admin_username
  ssh_public_key      = var.ssh_public_key
  tags                = local.common_tags
}

module "vm_api" {
  source = "../../modules/linux-vm"

  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  vm_name             = "vm-api-${var.project_code}-${var.environment}"
  subnet_id           = module.networking.subnet_ids["api"]
  vm_size             = var.vm_sizes["api"]
  admin_username      = var.admin_username
  ssh_public_key      = var.ssh_public_key
  tags                = local.common_tags
}

module "vm_ops" {
  source = "../../modules/linux-vm"

  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  vm_name             = "vm-ops-${var.project_code}-${var.environment}"
  subnet_id           = module.networking.subnet_ids["ops"]
  vm_size             = var.vm_sizes["ops"]
  admin_username      = var.admin_username
  ssh_public_key      = var.ssh_public_key
  enable_system_assigned_identity = true
  tags                = local.common_tags
}

module "ilb_web" {
  source = "../../modules/internal-load-balancer"

  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  name                = "ilb-web-${var.project_code}-${var.environment}"
  subnet_id           = module.networking.subnet_ids["web"]
  frontend_private_ip = var.frontend_ilb_ip
  backend_nic_id      = module.vm_web.network_interface_id
  backend_port        = 80
  probe_port          = 80
  probe_path          = "/"
  tags                = local.common_tags
}

module "ilb_api" {
  source = "../../modules/internal-load-balancer"

  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  name                = "ilb-api-${var.project_code}-${var.environment}"
  subnet_id           = module.networking.subnet_ids["api"]
  frontend_private_ip = var.backend_ilb_ip
  backend_nic_id      = module.vm_api.network_interface_id
  backend_port        = 8080
  probe_port          = 8080
  probe_path          = "/actuator/health"
  tags                = local.common_tags
}

module "app_gateway" {
  source = "../../modules/app-gateway"

  resource_group_name     = data.azurerm_resource_group.main.name
  location                = data.azurerm_resource_group.main.location
  project_code            = var.project_code
  environment             = var.environment
  subnet_id               = module.networking.subnet_ids["agw"]
  frontend_public_ip_name = var.appgw_public_ip_name
  frontend_ilb_ip         = module.ilb_web.frontend_private_ip
  backend_ilb_ip          = module.ilb_api.frontend_private_ip
  certificate_data        = var.appgw_certificate_data
  certificate_password    = var.appgw_certificate_password
  tags                    = local.common_tags
}
