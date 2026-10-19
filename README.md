# terraform-azure-lab
[![Terraform CI](https://github.com/a-elef93/terraform-azure-lab/actions/workflows/terraform.yml/badge.svg)](https://github.com/a-elef93/terraform-azure-lab/actions/workflows/terraform.yml)

Azure infrastructure provisioned with Terraform: resource group, virtual network, subnet, network security group, public IP, network interface and a Linux virtual machine reachable over SSH. State is stored remotely in Azure Storage.

Rebuilds, as code, a lab I originally created by hand in the Azure Portal. Everything is reproducible with a few commands and can be removed with a single `terraform destroy`.

## What it builds

| Resource | Terraform address | Azure name |
|---|---|---|
| Resource group | `azurerm_resource_group.lab` | `rg-terraform-lab` |
| Virtual network (`10.0.0.0/16`) | `azurerm_virtual_network.lab` | `vnet-terraform-lab` |
| Subnet (`10.0.1.0/24`) | `azurerm_subnet.subnet` | `subnet-web` |
| Network security group (allows SSH inbound) | `azurerm_network_security_group.web` | `nsg-web` |
| NSG-to-subnet association | `azurerm_subnet_network_security_group_association.nsg-bind` | n/a |
| Public IP (Standard, static) | `azurerm_public_ip.vm` | `pip-vm` |
| Network interface | `azurerm_network_interface.nic` | `eth-nic` |
| Linux VM (Ubuntu 24.04 LTS, SSH key only) | `azurerm_linux_virtual_machine.vm` | `vm-terraform-lab` |

Resources are wired together through references (for example `azurerm_resource_group.lab.name`), so Terraform works out the creation order on its own and destroys in the reverse order.

## Project structure

```
main.tf              backend, provider and resources
variables.tf         input variables (location, resource group name)
outputs.tf           values printed after apply (resource group id and name, VM public IP)
.terraform.lock.hcl  pinned provider version
```

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install)
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli), signed in with `az login`
- An Azure subscription. Put its id in the `provider "azurerm"` block in `main.tf`:

```bash
az account show --query id -o tsv
```

- An SSH key pair. The VM uses the public key from `~/.ssh/id_ed25519.pub` (`ssh-keygen -t ed25519` if you do not have one). No password is used anywhere.

## Remote state

State lives in an Azure Storage account in a **separate resource group** (`rg-tfstate`), created with the Azure CLI and not managed by this project. This way `terraform destroy` never deletes the state, and Terraform locks the state while it runs. Create it once:

```bash
az group create --name rg-tfstate --location swedencentral

az storage account create --name <unique-name> --resource-group rg-tfstate \
  --location swedencentral --sku Standard_LRS --min-tls-version TLS1_2 \
  --allow-blob-public-access false

az storage container create --name tfstate --account-name <unique-name> --auth-mode key
```

Then set `storage_account_name` in the `backend "azurerm"` block in `main.tf`. The storage account name must be globally unique (3-24 lowercase letters and digits).

## Usage

```bash
terraform init       # download the azurerm provider and configure the backend
terraform fmt        # format the code
terraform validate   # check the syntax
terraform plan       # preview the changes, nothing is created
terraform apply      # create the infrastructure
terraform output     # show the outputs
terraform destroy    # remove everything
```

Connect to the VM:

```bash
ssh azureuser@$(terraform output -raw vm_public_ip)
```

Verify the result independently of Terraform:

```bash
az group exists --name rg-terraform-lab
az resource list --resource-group rg-terraform-lab -o table
az network vnet subnet show --resource-group rg-terraform-lab \
  --vnet-name vnet-terraform-lab --name subnet-web \
  --query networkSecurityGroup.id -o tsv
```

## Variables

| Name | Default | Description |
|---|---|---|
| `location` | `swedencentral` | Azure region. Availability differs per subscription, so change it here if you get a `403 RequestDisallowedByAzure` error. |
| `resource_group_name` | `rg-terraform-lab` | Name of the resource group. |

## Cost

The VM, its public IP and OS disk are billed hourly while they exist. Stopping the VM from inside the operating system does not stop the charges. Run `terraform destroy` at the end of every session and confirm with `az group exists --name rg-terraform-lab` (it should print `false`). Setting a budget alert in Cost Management is recommended.

## Notes

- Before creating the VM, check that the size is allowed for your subscription: `az vm list-skus` shows restrictions and `az vm list-usage` shows the vCPU quota per VM family. `terraform plan` does not check availability or quota, so these problems only appear at `apply`.
- The state file is kept out of Git via `.gitignore`. State can contain sensitive values.
- `.terraform.lock.hcl` is committed so everyone uses the same provider version.
- The SSH rule in the NSG allows any source address. This is acceptable for a short-lived lab, but restrict `source_address_prefix` to your own IP for anything longer-lived.

## Roadmap

- VM size as a variable
- Modules
- Pipeline with GitHub Actions (`fmt`, `validate`, `plan` on pull requests)
