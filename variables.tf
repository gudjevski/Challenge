#variable "client_id" {
#    description     = " Service principle ID used for deployment"
#    type	       = "string"
#}
#
#variable "client_secret" {
#    description     = " Service principle SECRET used for deployment"
#    type	       = "string"
#}
#
#variable "tenant_id" {
#    description     = " Service principle Tenant ID used for deployment"
#    type	       = "string"
#}
#
#variable "subscription_id" {
#    description     = " Service principle Subscription ID used for deployment"
#    type	       = "string"
#}
#
#  USER THEM AS ENVIROMENT VARIABLES  FOR A SECURE REASON

variable "NameRG" {
    description     = "name of the resource group"
    type	       = "string"
}

variable "location" {
    description     = "Location"
    type	       = "string"
}
variable "vnet" {
    description     = "name of the virtual netwrok"
    type	       = "string"
}