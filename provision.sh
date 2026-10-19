#!/bin/bash

set -euo pipefail

echo "======================================"
echo "Starting Docker provisioning..."
echo "======================================"

# 1. Check if Docker is installed
if ! command -v docker &> /dev/null
then
    echo "Docker is not installed. Installing Docker..."

    # Install required package for repository management
    dnf -y install dnf-plugins-core

    # Add Docker repository
    dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

    # Install Docker
    dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
else
    echo "Docker is already installed."
fi


# 2. Start Docker service
echo "Starting Docker service..."
systemctl enable --now docker


# 3. Check for existing devops-web container
if docker ps -a --format '{{.Names}}' | grep -q '^devops-web$'
then
    echo "Existing devops-web container found."
    echo "Removing old container..."
    docker rm -f devops-web
fi


# 4. Copy the website out of the Vagrant shared folder. This avoids
#    SELinux denying nginx access to /vagrant inside the container.
echo "Preparing website files..."
rm -rf /opt/devops-web
mkdir -p /opt/devops-web

if [ -f /vagrant/website/index.html ]; then
    website_source=/vagrant/website
elif [ -f /vagrant/Website/index.html ]; then
    website_source=/vagrant/Website
else
    echo "ERROR: Could not find website/index.html in the Vagrant shared folder."
    exit 1
fi

cp -a "$website_source"/. /opt/devops-web/
chmod -R a+rX /opt/devops-web

if [ ! -f /opt/devops-web/index.html ]; then
    echo "ERROR: Website copy did not contain index.html."
    exit 1
fi


# 5. Run nginx container
echo "Starting nginx container..."

docker run -d \
    --name devops-web \
    -p 80:80 \
    -v /opt/devops-web:/usr/share/nginx/html:ro,Z \
    nginx:alpine


# 6. Display running container
echo "======================================"
echo "Running Docker containers:"
echo "======================================"

docker ps


# 7. Install curl if it is not available
if ! command -v curl &> /dev/null
then
    echo "Installing curl..."
    dnf -y install curl
fi


# 8. Check website HTTP response
echo "======================================"
echo "Checking website HTTP response:"
echo "======================================"

curl -I http://localhost

echo "======================================"
echo "Provisioning completed successfully!"
echo "======================================"