#!/bin/bash

# --- User-data script for Jenkins Agent (Slave) ---
# Designed for Amazon Linux 2

# Enable logging for user-data script execution
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo "--- Starting Jenkins Agent user-data script execution ---"

# Step 1: Update system packages
echo "Step 1/6: Updating system packages..."
yum update -y || { echo "ERROR: Failed to update system packages. Exiting."; exit 1; }
echo "System packages updated successfully."

# Step 2: Install Java (OpenJDK 11)
# This command is specific to Amazon Linux 2.
# For Amazon Linux 2023, you might use: dnf install -y java-17-amazon-corretto
echo "Step 2/6: Installing Java OpenJDK 11..."
amazon-linux-extras install java-openjdk11 -y || { echo "ERROR: Failed to install Java OpenJDK 11. Exiting."; exit 1; }
echo "Java OpenJDK 11 installed successfully."

# Step 3: Install common utilities (e.g., git, docker, unzip)
echo "Step 3/6: Installing common utilities (git, docker, unzip)..."
yum install -y git docker unzip || { echo "ERROR: Failed to install common utilities. Exiting."; exit 1; }
echo "Common utilities installed successfully."

# Step 4: Create a dedicated 'jenkinsadm' user and home directory
echo "Step 4/6: Creating 'jenkinsadm' user and configuring SSH access..."
useradd -m jenkinsadm || { echo "ERROR: Failed to create 'jenkinsadm' user. Exiting."; exit 1; }

# Create .ssh directory and set permissions
mkdir -p /home/jenkinsadm/.ssh || { echo "ERROR: Failed to create /home/jenkinsadm/.ssh directory. Exiting."; exit 1; }
chown jenkinsadm:jenkinsadm /home/jenkinsadm/.ssh || { echo "ERROR: Failed to set ownership for /home/jenkinsadm/.ssh. Exiting."; exit 1; }
chmod 700 /home/jenkinsadm/.ssh || { echo "ERROR: Failed to set permissions for /home/jenkinsadm/.ssh. Exiting."; exit 1; }

# Step 5: Configure Docker (Optional, but common for build agents)
echo "Step 5/6: Configuring Docker service and adding 'jenkinsadm' user to docker group..."
systemctl start docker || { echo "WARNING: Failed to start Docker service. Docker commands might not work."; }
systemctl enable docker || { echo "WARNING: Failed to enable Docker service. Docker might not start on reboot."; }
usermod -aG docker jenkinsadm || { echo "WARNING: Failed to add 'jenkinsadm' user to docker group. 'jenkinsadm' user might not be able to run Docker commands without sudo."; }
echo "Docker configured (if installed)."

# Step 6: Create a workspace directory for Jenkins jobs
echo "Step 6/6: Creating Jenkins workspace directory..."
mkdir -p /home/jenkinsadm/workspace || { echo "ERROR: Failed to create /home/jenkinsadm/workspace. Exiting."; exit 1; }
chown jenkinsadm:jenkinsadm /home/jenkinsadm/workspace || { echo "ERROR: Failed to set ownership for /home/jenkinsadm/workspace. Exiting."; exit 1; }
echo "Workspace directory created."

echo "--- Jenkins Agent user-data script execution completed ---"
echo ""
echo "--------------------------------------------------------------------------------"
echo "  Next Steps:"
echo "  1. Verify the 'jenkinsadm' user can SSH from your Jenkins controller."
echo "     (e.g., ssh -i /path/to/private_key jenkinsadm@<Agent_Public_IP>)"
echo "  2. In Jenkins, go to 'Manage Jenkins' -> 'Nodes' -> 'New Node'."
echo "  3. Configure the node with:"
echo "     - Name: (e.g., my-agent-01)"
echo "     - Remote root directory: /home/jenkinsadm/workspace"
echo "     - Host: <Agent_Public_IP_or_DNS>"
echo "     - Credentials: Select 'SSH Username with private key' for 'jenkinsadm' user."
echo "     - Host Key Verification Strategy: 'Non verifying Verification Strategy' (for testing, use 'Known hosts file' for production)."
echo "--------------------------------------------------------------------------------"