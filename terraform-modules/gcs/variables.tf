variable "name" {
  default     = "YOUR_APPLICATION"
  description = "The name of your application"
}

variable "env" {
  default     = "dev"
  description = "Environment"
}

variable "project_id" {
  default     = "YOUR_PROJECT_NAME"
  description = "Name of the project that will host GKE cluster"
}


variable "location" {
  default     = "YOUR_REGION"
  description = "Region that your resource will be created in"
}