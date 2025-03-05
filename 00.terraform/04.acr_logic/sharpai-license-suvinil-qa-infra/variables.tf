variable "azure_region" {
  type = string
}

variable "project_name" {
  type        = string
  description = "The name of project."
}

variable "environment" {
  type        = string
  description = "The environment of project."
}

variable "mock_acr_image_name" {
  type = string
  description = "Placeholder for image name"
  
}

variable "mock_acr_tag_name" {
  type = string
  description = "Placeholder for tag name"
  
}