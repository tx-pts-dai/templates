variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "@{{ app_name }}"
}

variable "environment" {
  description = "value of the environment tag"
  type        = string
}

variable "github_repo" {
  description = "Git repository name"
  type        = string
  default     = "@{{ github_repo }}"
}

variable "github_org" {
  description = "Git organization name"
  type        = string
  default     = "dnd-it"
}
