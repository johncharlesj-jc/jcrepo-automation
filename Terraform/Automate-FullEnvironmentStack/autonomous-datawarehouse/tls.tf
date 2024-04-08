# Generates Key Pair for Instnance
resource "tls_private_key" "key_pair" {
  algorithm = "RSA"
}
