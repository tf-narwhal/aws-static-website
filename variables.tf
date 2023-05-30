variable "project_name" {
  type        = string
  description = "The name of the project"
}

variable "domain" {
  type        = string
  description = "The domain name for the static website."
}

variable "description" {
  type        = string
  description = "The description to be used where applicable"
}

variable "role_arns" {
  description = "List of ARNs for the roles to which you want to grant access"
  type        = list(string)
  default     = []
}
