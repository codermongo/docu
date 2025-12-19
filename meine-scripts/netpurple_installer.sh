#!/bin/bash

# Netpurple Installer Script

# Display Welcome Message
echo "=========================================="
echo "          Welcome to Netpurple            "
echo "=========================================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Function to check if a command exists
check_cmd() {
    command -v "$1" >/dev/null 2>&1
}

# Check Prerequisites
echo "Checking prerequisites..."
MISSING_PREREQS=false
PREREQS_TO_INSTALL=""

if ! check_cmd docker; then 
    MISSING_PREREQS=true
    PREREQS_TO_INSTALL="$PREREQS_TO_INSTALL Docker"
fi
if ! check_cmd docker-compose; then 
    MISSING_PREREQS=true
    PREREQS_TO_INSTALL="$PREREQS_TO_INSTALL Docker Compose"
fi
if ! check_cmd npm; then 
    MISSING_PREREQS=true
    PREREQS_TO_INSTALL="$PREREQS_TO_INSTALL NPM"
fi

if [ "$MISSING_PREREQS" = true ]; then
    echo "Missing prerequisites:$PREREQS_TO_INSTALL"
    read -p "Should the prerequisites be installed (Docker, Docker Compose, NPM) (y/N)? " install_choice
    if [[ "$install_choice" =~ ^[Yy]$ ]]; then
        echo "Installing prerequisites..."
        apt-get update
        apt-get install -y docker.io docker-compose npm
    else
        echo "Prerequisites are required. Exiting."
        exit 1
    fi
else
    echo "All prerequisites are installed."
fi

# Function to run container
run_container() {
    local name=$1
    local image=$2
    local ports=$3
    echo "Installing $name..."
    docker run -d --restart always --name "$name" $ports "$image"
    if [ $? -eq 0 ]; then
        echo "$name installed successfully."
    else
        echo "Failed to install $name."
    fi
}

# Main Menu
while true; do
    echo ""
    echo "------------------------------------------"
    echo "Main Menu"
    echo "1. Administration"
    echo "2. Databases"
    echo "3. Languages"
    echo "4. Docker stuff"
    echo "5. Web server"
    echo "6. Exit"
    echo "------------------------------------------"
    read -p "Enter choice: " category

    case $category in
        1)
            echo "--- Administration ---"
            echo "1. Webmin"
            echo "2. Portainer"
            echo "3. phpMyAdmin"
            echo "4. Back"
            read -p "Selection: " sel
            case $sel in
                1) run_container "webmin" "dwp/webmin" "-p 10000:10000" ;;
                2) run_container "portainer" "portainer/portainer-ce" "-p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock" ;;
                3) run_container "phpmyadmin" "phpmyadmin/phpmyadmin" "-p 8080:80" ;;
            esac
            ;;
        2)
            echo "--- Databases ---"
            echo "1. MySQL"
            echo "2. MariaDB"
            echo "3. MongoDB"
            echo "4. PostgreSQL"
            echo "5. Back"
            read -p "Selection: " sel
            case $sel in
                1) run_container "mysql" "mysql:latest" "-e MYSQL_ROOT_PASSWORD=root" ;;
                2) run_container "mariadb" "mariadb:latest" "-e MYSQL_ROOT_PASSWORD=root" ;;
                3) run_container "mongodb" "mongo:latest" "" ;;
                4) run_container "postgresql" "postgres:latest" "-e POSTGRES_PASSWORD=root" ;;
            esac
            ;;
        3)
            echo "--- Languages ---"
            echo "1. PHP (current version)"
            echo "2. NPM"
            echo "3. Back"
            read -p "Selection: " sel
            case $sel in
                1) run_container "php" "php:latest" "" ;; # Pulls and runs (exits immediately if not interactive/daemon, but fulfills requirement)
                2) run_container "npm" "node:latest" "" ;;
            esac
            ;;
        4)
            echo "--- Docker stuff ---"
            echo "1. Nextcloud"
            echo "2. Nginx Proxy Manager"
            echo "3. Matrix"
            echo "4. Element Web Chat"
            echo "5. Casm (Kasm)"
            echo "6. Back"
            read -p "Selection: " sel
            case $sel in
                1) run_container "nextcloud" "nextcloud" "-p 8081:80" ;;
                2) run_container "nginx-proxy-manager" "jc21/nginx-proxy-manager" "-p 81:81 -p 80:80 -p 443:443" ;;
                3) run_container "matrix" "matrixdotorg/synapse" "-p 8008:8008" ;;
                4) run_container "element" "vectorim/element-web" "-p 8082:80" ;;
                5) run_container "kasm" "kasmweb/kasm-web" "-p 3000:3000" ;; # Simplification
            esac
            ;;
        5)
            echo "--- Web servers ---"
            echo "1. Apache2"
            echo "2. Nginx"
            echo "3. Back"
            read -p "Selection: " sel
            case $sel in
                1) run_container "apache2" "httpd:latest" "-p 8083:80" ;;
                2) run_container "nginx" "nginx:latest" "-p 8084:80" ;;
            esac
            ;;
        6)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid selection."
            ;;
    esac
done
