provider "vault" {
  address = var.vault_address
  skip_tls_verify = true
  #token = data.terraform_remote_state.hashistack.outputs.vault_token
  token = var.vault_token
}