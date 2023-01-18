provider "vault" {
  address = var.vault_address
  skip_tls_verify = true
  #token = data.terraform_remote_state.hashistack.outputs.vault_token
  token = var.vault_token
}

resource "vault_auth_backend" "userpass" {
  type = "userpass"

}


resource "vault_generic_endpoint" "joern" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/userpass/users/joern"
  ignore_absent_fields = true

    data_json = data.template_file.joern.rendered

}

data "template_file" "joern" {
  template = file("${path.root}/templates/joern.tpl") 
  vars = {
    policy = vault_policy.admins.name
    password = var.vault_joern_pw
  }
}

resource "vault_policy" "admins" {
  name = "vault-admins"

  policy = <<EOT

# Allow managing leases
path "sys/leases/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Manage auth backends broadly across Vault
path "auth/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# List, create, update, and delete auth backends
path "sys/auth/*"
{
  capabilities = ["create", "read", "update", "delete", "sudo"]
}

# List existing policies
path "sys/policies"
{
  capabilities = ["read"]
}

# Create and manage ACL policies broadly across Vault
path "sys/policies/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# List, create, update, and delete key/value secrets
path "secret/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Manage and manage secret backends broadly across Vault.
path "sys/mounts/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# List existing secret engines.
path "sys/mounts"
{
  capabilities = ["read"]
}

# Read health checks
path "sys/health"
{
  capabilities = ["read", "sudo"]
}

EOT
}