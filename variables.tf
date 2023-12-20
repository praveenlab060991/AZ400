variable "fw_rg_name"{
type=string
default="AZ400-RG"
description="RG name"
}

variable fw_vnet_name {
type=string
description="VNET name"
default="AZ400"
}
variable "fw_mgmt_subnet_name"{
type=string
description="mgmt subnet name"
default="AZ400-FW-MGMT"
}

variable "fw_trust_subnet_name"{
type=string
description="Trust subnet name"
default="AZ400-FW-Trust"
}

variable "fw_untrust_subnet_name"{
type=string
description="Untrust subnet name"
default="AZ400-FW-Unrust"
}