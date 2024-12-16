variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "@{{ cookiecutter.app_name }}"
}

variable "app_port" {
  description = "Application port number"
  type        = string
  default     = "@{{ cookiecutter.app_port }}"
}

variable "app_health_check_path" {
  description = "Application health check path"
  type        = string
  default     = "@{{ cookiecutter.app_health_check_path }}"
}
variable "environment" {
  description = "value of the environment tag"
  type        = string
}

variable "domain_name" {
  description = "Main domain name"
  type        = string
}

variable "acm_alternative_domain_names" {
  description = "list of alternative domain names"
  type        = list(string)
  default     = []
}

variable "github_repo" {
  description = "Name of the GitHub repository"
  type        = string
  default     = "@{{ cookiecutter.github_repo }}"
}

