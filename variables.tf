variable region {
    default = "ap-northeast-2"
}

variable "available_az" {
    default = [
        "ap-northeast-2a",
        "ap-northeast-2c"
    ]
}

variable name {
    default = "eks-vpc"
}

variable "vpc_cidr_blocks" {
    default = "10.0.0.0/16"
}
variable "public_cidr_blocks" {
    default = [
        "10.0.1.0/24",
        "10.0.2.0/24"
    ]
}

variable "private_cidr_blocks" {
    default = [
        "10.0.10.0/24",
        "10.0.11.0/24"
    ]
}
