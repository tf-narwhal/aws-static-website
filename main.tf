terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

module "tools" {
  source  = "git::https://github.com/tf-narwhal/toolbox.git//"
  # version = "1.0.0"
}
