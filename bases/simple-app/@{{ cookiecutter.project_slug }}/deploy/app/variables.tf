variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "@{{ cookiecutter.app_name }}"
}

variable "branch" {
  description = "Branch on the source repository from which the current deployment is originating"
  type        = string
  default     = ""
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

variable "image_tag" {
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

variable "app_health_check_path" {
  description = "application health check path"
  type        = string
  default     = "@{{ cookiecutter.app_health_check_path }}"
}

variable "domain_name" {
  description = "Main domain name"
  type        = string
}
