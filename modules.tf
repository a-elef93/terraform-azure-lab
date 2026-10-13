module "naming_dev" {
  source  = "./modules/naming"
  project = "tf"
  env     = "dev"
}

module "naming_prod" {
  source  = "./modules/naming"
  project = "tf"
  env     = "prod"
}

output "prefixes" {
  value = [module.naming_dev.prefix, module.naming_prod.prefix]
}
