terraform {
    required_version = ">= 0.12"

    backend "s3" {
        bucket = "engn.me.terraform.state"
        key = "eks-sample"
        region = "ap-northeast-2"
        encrypt = true
        acl = "bucket-owner-full-control"
    }
}

provider "aws" {
    region = var.region
}
