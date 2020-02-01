variable az {
    default = "ap-northeast-2"
}

variable name {
    default = "eks-vpc"
}

variable vpc_cidr_blocks {
    default = "10.0.0.0/16"
}

variable public1_subnet_cidr_blocks {
    default = "10.0.1.0/24"
}

variable public2_subnet_cidr_blocks {
    default = "10.0.2.0/24"
}

variable private1_subnet_cidr_blocks {
    default = "10.0.10.0/24"
}

variable private2_subnet_cidr_blocks {
    default = "10.0.11.0/24"
}
