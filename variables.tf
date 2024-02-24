variable "key_name" {
  description = "Nome da chave SSH para a instância EC2"
  default     = "arf-ec2-keypair"
}

variable "ami" {
  description = "ID da AMI a ser usada para a instância EC2"
  default     = "ami-04ab94c703fb30101" 
}