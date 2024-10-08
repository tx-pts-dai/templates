variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "@{{ cookiecutter.app_name }}"
}

variable "helm_deployment_annotations" {
  description = "Annotations to add to the Kubernetes Deployment"
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "value of the environment tag"
  type        = string
}

variable "github_org" {
  description = "Git organization name"
  type        = string
  default     = "dnd-it"
}

variable "github_repo" {
  description = "Git repository name"
  type        = string
  default     = "@{{ cookiecutter.github_repo }}"
}

variable "helm_enable_ingress" {
  description = "Enable ingress for the application"
  type        = bool
  default     = false
}

variable "helm_enable_scaling" {
  description = "Enable scaling (HPA) of the deployment"
  type        = bool
  default     = false
}

variable "helm_enable_target_group_binding" {
  description = "Enable binding to a target group"
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

variable "helm_image_tag" {
  description = "The tag of the image to deploy"
  type        = string
}

variable "helm_set" {
  description = "Values to pass to the Helm chart"
  type        = any
  default     = {}
}

variable "namespace" {
  description = "Kubernetes namespace to deploy the application into"
  type        = string
  default     = null
}

variable "tf_state_bucket" {
  description = "The name of the S3 bucket where Terraform states are stored"
  type        = string
}
