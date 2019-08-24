provider "aws" {
  profile    = "default"
  version    = "2.22.0"
  region     = "us-east-1"
}

provider "archive" {

}

variable "website_bucket" {
  default = "compx527-group3-stock-data-viewer-alex"#"compx527-group3-stock-data-viewer"
}

variable "lambda_bucket" {
  default = "compx526-group3-lambdas-alex"#"compx526-group3-lambdas"
}

variable "lambdas_version" {
  default = "1.0"
}