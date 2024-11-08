variable "tags" {
  description = "tas comunes para los recursos"
  type        = map(string)
  default = {
    Project = "laboratorio 4"
    Owner   = "carlosgb"
  }
}