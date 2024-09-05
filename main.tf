
terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.0.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

# the tls_private_key resource from the tls provider to generate RSA 4096-bit SSH keys.
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

#This function reads a template file (cloud-config.yaml.tpl) located in the module’s path and replaces the placeholders with the provided values.
#Use the local_file resource from the local provider to generate cloud-config.yaml by rendering cloud-config.yaml.tpl and filling placeholders with the generated SSH keys. 
#${path.module}: This is a special variable in Terraform that refers to the directory containing the module where the configuration is defined.
resource "local_file" "cloud_config" {
  content  = templatefile("${path.module}/cloud-config.yaml.tpl", {
    public_key  = tls_private_key.ssh_key.public_key_openssh
    private_key = tls_private_key.ssh_key.private_key_pem
  })
  filename = "${path.module}/cloud-config.yaml"
}
