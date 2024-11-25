#!/bin/bash
#
CUSTOM_DIR="./keys/vm"

# Create the custom directory if it doesn't exist
mkdir -p "$CUSTOM_DIR"

terraform plan
terraform apply -auto-approve

terraform output -raw ubuntu_vm_private_key > "$CUSTOM_DIR/private_key.pem"
chmod 600 "$CUSTOM_DIR/private_key.pem" # Secure the private key

# Extract the public key from Terraform outputs and save it
terraform output -raw ubuntu_vm_public_key > "$CUSTOM_DIR/public_key.pub"

# Save all Terraform outputs to a JSON file in the custom directory
terraform output -json > "outputs.json"

# Notify the user of the locations
echo "Keys and outputs have been saved in: $CUSTOM_DIR"
echo "Private Key: $CUSTOM_DIR/private_key.pem"
echo "Public Key: $CUSTOM_DIR/public_key.pub"
echo "Outputs File: outputs.json"

