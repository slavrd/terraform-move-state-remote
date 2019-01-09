terraform {
  backend "atlas" {
    name = "slavrdorg/terraform-move-state-pet"
  }
}

resource "random_pet" "pet" {
  length    = "4"
  separator = "-"
}

output "random_pet_name" {
  value = "${random_pet.pet.id}"
}
