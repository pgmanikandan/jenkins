#!/bin/bash

# Enable logging to /var/log/user-data.log and console
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo "--- Starting user-data script execution ---"

# Update system packages
echo "Step 1/6: Updating system packages..."
yum update -y || { echo "ERROR: Failed to update system packages. Exiting."; exit 1; }
echo "System packages updated successfully."

# Install Jenkins repository
echo "Step 2/6: Adding Jenkins repository..."
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo || { echo "ERROR: Failed to download Jenkins repository file. Exiting."; exit 1; }
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key || { echo "ERROR: Failed to import Jenkins GPG key. Exiting."; exit 1; }
echo "Jenkins repository added and GPG key imported."

# Install Jenkins and Java 17 (Amazon Corretto)
echo "Step 3/6: Installing Jenkins and Java 17 (Amazon Corretto)..."
yum install -y jenkins java-17-amazon-corretto || { echo "ERROR: Failed to install Jenkins or Java. Exiting."; exit 1; }
echo "Jenkins and Java 17 installed successfully."

# Start and enable Jenkins service
echo "Step 4/6: Starting and enabling Jenkins service..."
systemctl start jenkins || { echo "ERROR: Failed to start Jenkins service. Exiting."; exit 1; }
systemctl enable jenkins || { echo "ERROR: Failed to enable Jenkins service. Exiting."; exit 1; }
echo "Jenkins service started and enabled."

# Wait for Jenkins to become available
echo "Step 5/6: Waiting for Jenkins to become available on http://localhost:8080 (max 300 seconds)..."
timeout 300 bash -c 'until curl -s http://localhost:8080 > /dev/null; do sleep 5; done'
if [ $? -ne 0 ]; then
    echo "ERROR: Jenkins did not start within 300 seconds. Please check Jenkins logs for issues."
    exit 1
fi
echo "Jenkins is up and running."

# Retrieve and display the initial admin password
echo "Step 6/6: Retrieving initial Jenkins admin password..."
initial_admin_password=$(cat /var/lib/jenkins/secrets/initialAdminPassword 2>/dev/null)
if [ -z "$initial_admin_password" ]; then
    echo "ERROR: Could not retrieve initial Jenkins admin password. Check /var/lib/jenkins/secrets/initialAdminPassword."
    exit 1
fi
echo ""
echo "--------------------------------------------------------------------------------"
echo "  Jenkins initial admin password: $initial_admin_password"
echo "--------------------------------------------------------------------------------"
echo "  Please keep this password safe. You will need it to unlock Jenkins"
echo "  when you first access it via the web browser."
echo ""
echo "  To access Jenkins, navigate to: http://<Your_EC2_Public_IP_or_DNS>:8080"
echo "  *IMPORTANT*: Ensure that port 8080 is open in your AWS Security Group"
echo "               for inbound traffic from your IP address or 0.0.0.0/0 (for testing)."
echo ""
echo "--- User-data script execution completed ---"