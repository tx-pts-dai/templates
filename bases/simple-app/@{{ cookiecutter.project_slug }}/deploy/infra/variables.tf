variable "metadata" {
  description = "Metadata"
  type        = object({
    environment = string
    github_repo = string
    github_org  = string
  })
}

variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "@{{ cookiecutter.app_name }}"
}

variable "app_subdomain" {
  description = "The subdomain of the application. This can be empty if the application host is the root domain."
  type        = string
  default     = "@{{ cookiecutter.app_subdomain }}"
}

variable "environment" {
  description = "value of the environment tag"
  type        = string
}

variable "github_repo" {
  description = "Git repository name"
  type        = string
  default     = "@{{ cookiecutter.project_slug }}"
}

variable "github_org" {
  description = "Git organization name"
  type        = string
  default     = ""
}

variable "zone_name" {
  description = "The domain name of the DNS zone"
  type        = string
}
