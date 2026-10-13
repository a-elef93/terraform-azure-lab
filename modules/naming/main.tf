variable "project" {
  type = string
}

variable "env" {
  type = string
}

output "prefix" {
  value = "${var.project}-${var.env}"
}
