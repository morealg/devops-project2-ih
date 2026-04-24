resource "azurerm_public_ip" "appgw" {
  name                = var.frontend_public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

resource "azurerm_application_gateway" "main" {
  name                = "agw-${var.project_code}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 1
  }

  waf_configuration {
    enabled          = true
    firewall_mode    = "Detection"
    rule_set_type    = "OWASP"
    rule_set_version = "3.2"
  }

    ssl_policy {
    policy_type          = "Predefined"
    policy_name          = "AppGwSslPolicy20220101"
  }

  gateway_ip_configuration {
    name      = "gateway-ip-config"
    subnet_id = var.subnet_id
  }

  frontend_port {
    name = "https-port"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "public-frontend"
    public_ip_address_id = azurerm_public_ip.appgw.id
  }

   ssl_certificate {
    name     = "appgw-cert"
    data     = var.certificate_data
    password = var.certificate_password
  }

  backend_address_pool {
    name         = "frontend-backend-pool"
    ip_addresses = [var.frontend_ilb_ip]
  }

  backend_address_pool {
    name         = "api-backend-pool"
    ip_addresses = [var.backend_ilb_ip]
  }

  backend_http_settings {
    name                  = "frontend-http-settings"
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
    probe_name            = "frontend-probe"
  }

  backend_http_settings {
    name                  = "api-http-settings"
    cookie_based_affinity = "Disabled"
    path                  = "/actuator/health"
    port                  = 8080
    protocol              = "Http"
    request_timeout       = 30
    probe_name            = "api-probe"
  }

  http_listener {
    name                           = "https-listener"
    frontend_ip_configuration_name = "public-frontend"
    frontend_port_name             = "https-port"
    protocol                       = "Https"
    ssl_certificate_name           = "appgw-cert"
  }

  probe {
    name                = "frontend-probe"
    protocol            = "Http"
    host                = var.frontend_ilb_ip
    path                = "/"
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
    port                = 80
  }

  probe {
    name                = "api-probe"
    protocol            = "Http"
    host                = var.backend_ilb_ip
    path                = "/actuator/health"
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
    port                = 8080
  }

  url_path_map {
    name                               = "main-path-map"
    default_backend_address_pool_name  = "frontend-backend-pool"
    default_backend_http_settings_name = "frontend-http-settings"

    path_rule {
      name                       = "api-path-rule"
      paths                      = ["/api/*"]
      backend_address_pool_name  = "api-backend-pool"
      backend_http_settings_name = "api-http-settings"
    }
  }

  request_routing_rule {
    name               = "https-routing-rule"
    rule_type          = "PathBasedRouting"
    http_listener_name = "https-listener"
    url_path_map_name  = "main-path-map"
    priority           = 100
  }

  tags = var.tags
}
