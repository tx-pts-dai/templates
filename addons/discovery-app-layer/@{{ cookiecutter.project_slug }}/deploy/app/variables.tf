variable "app_name" {
  description = "Name of the application. Do not use var.app_name directly, use local.app_name instead."
  type        = string
  default     = "@{{ cookiecutter.app_name }}"
}

variable "branch" {
  description = "Branch on the source repository from which the current deployment is originating"
  type        = string
  default     = "main"
}

variable "environment" {
  description = "Value of the environment tag"
  type        = string
}

variable "github_org" {
  description = "Name of the GitHub organization"
  type        = string
  default     = "@{{ cookiecutter.github_org }}"
}

variable "github_repo" {
  description = "Name of the GitHub repository"
  type        = string
  default     = "@{{ cookiecutter.github_repo }}"
}

variable "helm_deployment_annotations" {
  description = "Annotations to add to the Kubernetes Deployment"
  type        = map(string)
  default     = {}
}

variable "helm_enable_scaling" {
  description = "Enable scaling (HPA) of the deployment"
  type        = bool
  default     = false
}

variable "helm_env_vars" {
  description = "Environment variables to pass to the Helm"
  type        = any
  default     = {}
}

variable "helm_external_secrets" {
  description = "List of external secrets to fetch"
  type        = list(string)
  default     = []
}

variable "helm_set" {
  description = "Values to pass to the Helm chart"
  type        = any
  default     = {}
}

variable "image_tag" {
  description = "The tag of the image to deploy"
  type        = string
}

variable "preview_branch" {
  description = "Enable preview branch resources"
  type        = bool
  default     = false
}

variable "zone_name" {
  description = "The name of the Route53 zone to use for the application."
  type        = string
}

