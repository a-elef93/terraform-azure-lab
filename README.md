# terraform-azure-lab

Azure network infrastructure (resource group, virtual network, subnet, network security group) provisioned with Terraform.

Rebuilds, as code, a lab I originally created by hand in the Azure Portal. Everything is reproducible with a few commands and can be removed with a single `terraform destroy`.

## What it builds

| Resource | Terraform address | Azure name |
|---|---|---|
| Resource group | `azurerm_resource_group.lab` | `rg-terraform-lab` |
| Virtual network (`10.0.0.0/16`) | `azurerm_virtual_network.lab` | `vnet-terraform-lab` |
| Subnet (`10.0.1.0/24`) | `azurerm_subnet.subnet` | `subnet-web` |
| Network security group (allows SSH inbound) | `azurerm_network_security_group.web` | `nsg-web` |
| NSG-to-subnet association | `azurerm_subnet_network_security_group_association.nsg-bind` | nsg-bind |

Resources are wired together through references (for example `azurerm_resource_group.lab.name`), so Terraform works out the creation order on its own and destroys in the reverse order.

## Project structure

```
main.tf              provider and resources
variables.tf         input variables (location, resource group name)
outputs.tf           values printed after apply (resource group id and name)
.terraform.lock.hcl  pinned provider version
```

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install)
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli), signed in with `az login`
- An Azure subscription. Put its id in the `provider "azurerm"` block in `main.tf`:

```bash
az account show --query id -o tsv
```

## Usage

```bash
terraform init       # download the azurerm provider
terraform fmt        # format the code
terraform validate   # check the syntax
terraform plan       # preview the changes, nothing is created
terraform apply      # create the infrastructure
terraform output     # show the outputs
terraform destroy    # remove everything
```

Verify the result independently of Terraform:

```bash
az group exists --name rg-terraform-lab
az network vnet subnet show --resource-group rg-terraform-lab \
  --vnet-name vnet-terraform-lab --name subnet-web \
  --query networkSecurityGroup.id -o tsv
```

## Variables

| Name | Default | Description |
|---|---|---|
| `location` | `northeurope` | Azure region. Some regions do not accept new resources on every subscription, so change it here if you get a `403 RequestDisallowedByAzure` error. |
| `resource_group_name` | `rg-terraform-lab` | Name of the resource group. |

## Notes

- The state file (`terraform.tfstate`) is intentionally not committed. State can contain sensitive values, so it is kept out of Git via `.gitignore`.
- `.terraform.lock.hcl` is committed so everyone uses the same provider version.
- The SSH rule in the NSG allows any source address. This is acceptable for a short-lived lab, but restrict `source_address_prefix` to your own IP for anything longer-lived.

## Roadmap

- Linux virtual machine with a public IP and SSH key authentication
- Remote state in Azure Storage
- Pipeline with GitHub Actions (`fmt`, `validate`, `plan` on pull requests)
