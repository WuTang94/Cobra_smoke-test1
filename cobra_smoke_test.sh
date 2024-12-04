#!/bin/bash
# Author: Justin Tang
# Version: 1.2
# Date: November 17, 2024
# Script created with assistance from Microsoft Copilot

packages=("gcc" "tcl tk" "graphviz" "bison")
retry_attempts=3

#method to check for prequisite packages
check_and_install() {
    package=$1
    for ((i=1; i<=retry_attempts; i++)); do
        if dpkg -l | grep -qw $package; then
            echo "$package is already installed."
            return 0
        else
            echo "$package is not installed. Attempting to install ($i/$retry_attempts)..."
            sudo apt-get install -y $package
        fi
    done

    if dpkg -l | grep -qw $package; then
        echo "$package successfully installed."
        return 0
    else
        echo "Failed to install $package after $retry_attempts attempts."
        return 1
    fi
}

verify_src_directory() {
    rsync --dry-run --recursive --itemize-changes ../src/ https://github.com/nimble-code/Cobra/tree/master/src > rsync_output.txt
    if [ -s rsync_output.txt ]; then
        echo "/src/ folder is not the same. You may want to restore the folder or re-clone this repository before continuing."
        exit 1
    else
        echo "/src/ folder matches the GitHub repository."
    fi
}

create_src_directory() {
    if make -C src/; then
        echo "src/ directory created successfully."
    else
        echo "Failed to create src/ directory. Exiting."
        exit 1
    fi
}

# Function to export COBRA with the current directory and verify it 
set_cobra() { 
	export COBRA=$(pwd) 
	# Verify the export 
	if [ "$COBRA" == "$(pwd)" ]; then 
		echo "Success: COBRA is set correctly"
       	else 
		echo "Fail: COBRA is not set correctly" 
	fi 
}

copy_cobra_binary() {
    if sudo cp src/cobra /usr/local/bin; then
        echo "cobra copied to /usr/local/bin successfully."
    else
        echo "Failed to copy cobra to /usr/local/bin. Exiting."
        exit 1
    fi
}

configure_cobra() {
    if cobra -configure rules/; then
        echo "cobra configured successfully."
    else
        echo "Failed to configure cobra. Exiting."
        exit 1
    fi
}

run_basic_cobra_command() {
    if cobra README.md; then
        echo "Basic cobra command ran successfully."
    else
        echo "Failed to run basic cobra command. Exiting."
        exit 1
    fi
}

run_tcl_tk_gui() {
    if your_tcl_tk_command; then
        echo "Tcl/Tk GUI command ran successfully."
    else
        echo "Failed to run Tcl/Tk GUI command. Exiting."
        exit 1
    fi
}

# Main execution
for package in "${packages[@]}"; do
    check_and_install $package
    if [ $? -ne 0 ]; then
        echo "Failed to install $package. Exiting."
        exit 1
    fi
done

echo "All packages are installed successfully."
verify_src_directory
create_src_directory
copy_cobra_binary
configure_cobra
run_basic_cobra_command
#run_tcl_tk_gui
