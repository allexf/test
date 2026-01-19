module "webapp" {
  source = "../../modules/azure_webapp_container"

  name                = "staging-webapp"
  location            = var.location
  resource_group_name = var.resource_group_name
  container_image     = var.container_image
  tags                = local.common_tags
}

module "static_site" {
  source = "../../modules/azure_static_site"

  name                = "stagingsitestatic"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.common_tags
}

module "cdn" {
  source = "../../modules/azure_cdn"

  name                = "staging-cdn"
  location            = var.location
  resource_group_name = var.resource_group_name
  origin_host_name    = replace(module.static_site.primary_web_endpoint, "https://", "")
  tags                = local.common_tags
}

