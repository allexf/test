resource "azurerm_cdn_profile" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard_Microsoft"

  tags = var.tags
}

resource "azurerm_cdn_endpoint" "this" {
  name                = "${var.name}-endpoint"
  profile_name        = azurerm_cdn_profile.this.name
  location            = var.location
  resource_group_name = var.resource_group_name

  origin {
    name      = "origin"
    host_name = var.origin_host_name
  }

  is_http_allowed  = true
  is_https_allowed = true

  tags = var.tags
}

