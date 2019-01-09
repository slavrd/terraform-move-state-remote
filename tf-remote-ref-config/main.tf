data "terraform_remote_state" "remote_pet" {
  backend = "atlas"

  config {
    name = "slavrdorg/terraform-move-state-pet"
  }
}

resource "null_resource" "hello" {
  provisioner "local-exec" {
    command = "echo Hello ${data.terraform_remote_state.remote_pet.random_pet_name}"
  }
}

output "remote_pet_name" {
  value = "${data.terraform_remote_state.remote_pet.random_pet_name}"
}
