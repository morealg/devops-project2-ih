resource_group_name = "project2-burgerbuilder-team-5"
location            = "West US 2"
environment         = "dev"
project_name        = "burgerbuilder_project"
project_code        = "bb"
admin_username      = "azureuser"

vnet_address_space = ["10.20.0.0/16"]

subnet_address_prefixes = {
  agw               = ["10.20.1.0/24"]
  web               = ["10.20.2.0/24"]
  api               = ["10.20.3.0/24"]
  ops               = ["10.20.4.0/24"]
  private_endpoints = ["10.20.5.0/24"]
}

sql_server_name    = "sql-bb-dev-team5"
sql_database_name  = "burgerbuilderdb"
sql_admin_username = "sqladminuser"

key_vault_name         = "kv-bb-dev-team5"
tenant_id              = "84f58ce9-43c8-4932-b908-591a8a3007d3"
current_user_object_id = "759e6ac7-2930-4b9d-a50e-f920b6f693e2"

vm_sizes = {
  web = "Standard_D2s_v3"
  api = "Standard_D2s_v3"
  ops = "Standard_D2s_v3"
}

frontend_ilb_ip = "10.20.2.10"
backend_ilb_ip  = "10.20.3.10"

appgw_public_ip_name = "pip-agw-bb-dev"
