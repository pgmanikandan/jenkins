variable "ami" {
}
variable "aws_region" {
}
variable "instance_type" {
}
variable "key_name" {
}
variable "security_groups" {
}
variable "instance_count" {
}
variable "instance_names" {
  description = "1 Jenkins instance create"
  type        = list(string)
}
variable "slave_instance_names" {
  description = "1 Jenkins slave instance create"
  type        = list(string)
}
