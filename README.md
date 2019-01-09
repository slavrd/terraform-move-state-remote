# Terraform move state remote

A Terraform project that demonstrates how to move some resources from a project with a local backend to a different project with a remote backed. This is done without recreating the moved resources. Their properties can still be referenced in the initial project by using outputs defined the second project.

## Prerequisites

* Install terraform - [instructions](https://www.terraform.io/downloads.html)

To use the atlas remote backend:

* Create a Terraform Enterprise account in [here](https://app.terraform.io/account/new)
* In TFE create an organization and workspace.
* Create a TFE access [token](https://www.terraform.io/docs/enterprise/users-teams-organizations/users.html#api-tokens) and set it in env variable - `export ATLAS_TOKEN=<your_token>`

## Running the project

### Create a TF project with a local state

Create a TF project that provisions two resources -  a null_resource and a random_pet. The random_pet id is referenced by the null_resource and an output.

1. Copy the configuration - `cp tf-initial-config/main.tf .`
2. Initialize the project - `terraform init`
3. Apply the configuration - `terraform apply`

### Move the Random_pet resource to a different project

Move the random pet resource to another project which uses a remote backend to store its state.

1. Go to the new project's directory - `cd tf-pet-remote`
2. Move the random_pet - `terraform state mv -state=../terraform.tfstate -state-out=terraform.tfstate random_pet.pet random_pet.pet`. This will create a local state file containing the moved resource.
3. Configure the remote backend. Edit the `backend` section in `main.tf` as follows:

    ```HCL
    terraform {
        backend "atlas" {
            name = "your_tfe_organization/your_tfe_workspace"
        }
    }
    ```

4. Initialize the project - `terraform init`. This will initialize the remote backend and push the local state file to it.
5. Run `terraform refresh`, so that the output defined in the configuration will reference the moved resource.

### Change the initial project configuration

In the initial project we need to remove the random_pet resource definition and update all references to it. The random_pet should now be referenced by using the remote state output of the second project.

1. In the root directory of the repository overwrite the configuration of the initial project `cp tf-remote-ref-config/main.tf .`
2. In the new `main.tf` configure the remote state backend:

    ```HCL
    data "terraform_remote_state" "remote_pet" {
        backend = "atlas"

        config {
            name = "your_tfe_organization/your_tfe_workspace"
        }
    }
    ```
3. Run `terraform refresh`

 At this point

* If you run `terraform plan/apply` it will say that no changes are needed (even though the random_pet resource was removed from the configuration)
* The references to the random_pet still provide the same Id as it was not recreated during the move process
* If you run `terraform destroy` - it will destroy all resources present in the project's local state