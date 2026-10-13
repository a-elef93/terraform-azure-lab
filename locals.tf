locals {
  name_prefix = "${var.resource_group_name}-vm"
  common_tags = {
    project = "terraform-lab"
    owner   = "tasos"
  }
  subnets = {
    web = "10.0.1.0/24"
    db  = "10.0.2.0/24"
  }
}
