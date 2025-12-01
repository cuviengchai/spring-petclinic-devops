#!/bin/bash

set -e  # Exit on any error

# Function to check if script is run as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root (use sudo)"
        exit 1
    fi
}

# Function to create user account
create_user() {
    local username=$1
    local password=$2
    
    echo "Creating user: $username"
    
    # Check if user already exists
    if id "$username" &>/dev/null; then
        echo "User $username already exists. Skipping user creation."
    else
        # Create user with home directory and bash shell
        useradd -m -s /bin/bash "$username"
        echo "$username:$password" | chpasswd
        echo "User $username created successfully."
    fi
}

# Main execution
main() {
    echo "Starting SSH client setup automation..."
    
    # Check if running as root
    check_root
    
    # Get user input
    read -p "Enter username for SSH client: " USERNAME
    read -p "Enter remote host (e.g., ssh-server or IP address): " REMOTE_HOST
    read -s -p "Enter password for user $USERNAME: " PASSWORD
    echo ""
    
    # Validate input
    if [[ -z "$USERNAME" || -z "$REMOTE_HOST" || -z "$PASSWORD" ]]; then
        echo "Error: All fields are required."
        exit 1
    fi
    
    echo "Configuration:"
    echo "  Username: $USERNAME"
    echo "  Remote Host: $REMOTE_HOST"
    echo ""
    
    # Execute setup steps
    create_user "$USERNAME" "$PASSWORD"
    
    echo ""
    echo "Switching to user $USERNAME to continue setup..."
    
    # Switch to the new user and execute remaining functions
    su - "$USERNAME" << EOF
# Generate SSH keys as the user
echo "Generating SSH keys for user: $USERNAME"

# Create .ssh directory if it doesn't exist
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Generate Ed25519 key pair (modern and secure)
if [[ ! -f ~/.ssh/id_ed25519 ]]; then
    ssh-keygen -t ed25519 -C '$USERNAME@ssh-client' -f ~/.ssh/id_ed25519 -N ''
    echo "SSH key pair generated successfully."
else
    echo "SSH key pair already exists. Skipping key generation."
fi

# Set proper permissions
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub

echo ""
echo "Public key generated. Now copying to remote host..."
echo "Copying public key to remote host: $REMOTE_HOST"

# Copy public key to remote host
ssh-copy-id $USERNAME@$REMOTE_HOST

echo ""
echo "Testing SSH connection to $REMOTE_HOST..."
echo "Testing connection with key-based authentication..."

# Test SSH connection
ssh -o BatchMode=yes -o ConnectTimeout=10 $USERNAME@$REMOTE_HOST 'echo "SSH connection successful! Key-based authentication is working."' 2>/dev/null

if [[ \$? -eq 0 ]]; then
    echo "SSH connection test passed!"
    echo "You can now run: ssh $USERNAME@$REMOTE_HOST"
else
    echo "SSH connection test failed. Please check your setup."
    exit 1
fi
EOF
    
    
    echo ""
    echo "==============================================="
    echo "    Setup Complete!"
    echo "==============================================="
    echo "You can now SSH to the remote host using:"
    echo "  su - $USERNAME"
    echo "  ssh $USERNAME@$REMOTE_HOST"
}

# Run main function
main "$@"
