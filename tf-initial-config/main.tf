resource "random_pet" "pet" {
  length    = "4"
  separator = "-"
}

resource "null_resource" "hello" {
  provisioner "local-exec" {
    command = "echo Hello ${random_pet.pet.id}"
  }
}
