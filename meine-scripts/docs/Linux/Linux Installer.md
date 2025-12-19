# Linux Installer

The Linux Installer script (`netpurple_installer.sh`) is a comprehensive tool designed to automate the setup of various services and applications on Debian-like systems (including Ubuntu). It simplifies the process of installing Docker, managing system prerequisites, and deploying both containerized and system-level applications.

## Location

[Github[Netpurple Installer]](https://github.com/codermongo/docu/blob/main/Scripts/Linux/netpurple_installer.sh)

## Features

The installer includes an interactive menu with the following categories:

*   **Administration**: Tools for system management (Webmin, Portainer, phpMyAdmin).
*   **Databases**: Common database servers (MySQL, MariaDB, MongoDB, PostgreSQL).
*   **Languages**: Programming language runtimes and package managers (PHP, NPM).
*   **Docker Stuff**: Popular self-hosted applications running in containers (Nextcloud, Nginx Proxy Manager, Matrix, Element, Kasm).
*   **Web Servers**: Web server software (Apache2, Nginx).

## How to Use

1.  **Prerequisites**: The script automatically checks for `docker`, `docker-compose`, and `npm`. If missing, it offers to install them.
2.  **Execution**: Run the script as root:
    ```bash
    sudo ./netpurple_installer.sh
    ```
3.  **Navigation**: Follow the on-screen menu to select the category and application you wish to install.

## Source Code

```bash
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
    echo "Installing $name (Docker)..."
    docker run -d --restart always --name "$name" $ports "$image"
    if [ $? -eq 0 ]; then
        echo "$name installed successfully."
    else
        echo "Failed to install $name."
    fi
}

# Function to install system package
install_system_package() {
    local package=$1
    echo "Installing $package (System)..."
    apt-get install -y "$package"
    if [ $? -eq 0 ]; then
        echo "$package installed successfully."
    else
        echo "Failed to install $package."
    fi
}

# Function for Webmin specific install
install_webmin() {
    echo "Installing Webmin..."
    wget http://www.webmin.com/download/deb/webmin-current.deb
    dpkg -i webmin-current.deb
    apt-get -f install -y
    rm webmin-current.deb
    echo "Webmin installation attempt complete."
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
            echo "1. Webmin (System)"
            echo "2. Portainer (Docker)"
            echo "3. phpMyAdmin (System)"
            echo "4. Back"
            read -p "Selection: " sel
            case $sel in
                1) install_webmin ;; 
                2) run_container "portainer" "portainer/portainer-ce" "-p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock" ;; 
                3) install_system_package "phpmyadmin" ;; 
            esac
            ;; 
        2)
            echo "--- Databases ---"
            echo "1. MySQL (System)"
            echo "2. MariaDB (System)"
            echo "3. MongoDB (System)"
            echo "4. PostgreSQL (System)"
            echo "5. Back"
            read -p "Selection: " sel
            case $sel in
                1) install_system_package "mysql-server" ;; 
                2) install_system_package "mariadb-server" ;; 
                3) install_system_package "mongodb" ;; 
                4) install_system_package "postgresql" ;; 
            esac
            ;; 
        3)
            echo "--- Languages ---"
            echo "1. PHP (System)"
            echo "2. NPM (System)"
            echo "3. Back"
            read -p "Selection: " sel
            case $sel in
                1) install_system_package "php" ;; 
                2) install_system_package "npm" ;; 
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
                5) run_container "kasm" "kasmweb/kasm-web" "-p 3000:3000" ;; 
            esac
            ;; 
        5)
            echo "--- Web servers ---"
            echo "1. Apache2 (System)"
            echo "2. Nginx (System)"
            echo "3. Back"
            read -p "Selection: " sel
            case $sel in
                1) install_system_package "apache2" ;; 
                2) install_system_package "nginx" ;; 
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
```