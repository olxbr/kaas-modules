terraform {
  required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~>4.0.0"
      }

      restapi = {
        source = "Mastercard/restapi"
        version = "~>1.16.1"
      } 

      http = {
        source = "hashicorp/http"
        version = "~>2.1.0"
      }
  }
}