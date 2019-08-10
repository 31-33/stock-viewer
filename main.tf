provider "aws" {
  profile    = "default"
  version    = "2.22.0"
  region     = "us-east-1"
}

variable "website_bucket" {
  default = "compx527-group3-stock-data-viewer"
}
