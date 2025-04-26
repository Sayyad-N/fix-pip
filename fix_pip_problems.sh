#!/bin/bash

# ======================================
#  ____  __  _  _        ____  __  ____
# (  __)(  )( \/ )      (  _ \(  )(  _ \
#  ) _)  )(  )  (  ____  ) __/ )(  ) __/
# (__)  (__)(_/\_)(____)(__)  (__)(__)
# ======================================
#      Pip Environment Fix Tool
# ======================================

fix_pip_conf() {
    echo "Updating /etc/pip.conf..."
    sudo bash -c 'cat > /etc/pip.conf' <<EOF
[global]
break-system-packages = true
EOF
    echo "/etc/pip.conf updated."
}

add_python_alias() {
    echo "Adding alias to .bashrc if not already present..."
    if ! grep -q "alias python=" ~/.bashrc; then
        echo "alias python='python3'" >> ~/.bashrc
        echo "Alias added."
    else
        echo "Alias already exists in .bashrc"
    fi
}

fix_pip_problems() {
    echo "Fixing pip-related problems..."

    echo "1. Ensuring pip is installed and up to date..."
    python3 -m ensurepip --upgrade
    python3 -m pip install --upgrade pip setuptools wheel

    echo "2. Checking for broken pip installations..."
    if command -v pip3 >/dev/null 2>&1; then
        pip3 check
    else
        echo "pip3 is not installed or not found in PATH."
    fi

    echo "3. Reinstalling pip if necessary (use only if pip is badly broken)..."
    read -p "Reinstall pip? (y/N): " choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        python3 -m ensurepip --default-pip --upgrade
        python3 -m pip install --force-reinstall pip
        echo "Pip reinstalled."
    fi

    echo "Pip repair actions complete."
}

check_common_pip_issues() {
    echo "Checking for common pip issues..."

    echo "1. Checking if pip is installed..."
    if ! command -v pip3 >/dev/null 2>&1; then
        echo "pip3 is not installed. Attempting to install..."
        python3 -m ensurepip --upgrade
    else
        echo "pip3 is installed."
    fi

    echo "2. Checking if pip is in PATH..."
    if ! echo "$PATH" | grep -q "$(python3 -m site --user-base)/bin"; then
        echo "pip's user base binary directory is not in PATH."
        echo "Consider adding $(python3 -m site --user-base)/bin to your PATH."
    else
        echo "pip's user base binary directory is in PATH."
    fi

    echo "3. Checking for virtual environment..."
    if [ -n "$VIRTUAL_ENV" ]; then
        echo "Virtual environment detected at $VIRTUAL_ENV"
    else
        echo "No virtual environment detected."
    fi

    echo "4. Checking for network connectivity to PyPI..."
    if ping -c 1 pypi.org >/dev/null 2>&1; then
        echo "Network connectivity to PyPI is OK."
    else
        echo "Cannot reach pypi.org. Check your network connection or proxy settings."
    fi

    echo "Common pip issue checks complete."
}

# Menu
clear
echo "======================================"
echo " ____  __  _  _        ____  __  ____ "
echo "(  __)(  )( \/ )      (  _ \(  )(  _ \\"
echo " ) _)  )(  )  (  ____  ) __/ )(  ) __/"
echo "(__)  (__)(_/\_)(____)(__)  (__)(__)  "
echo "======================================"
echo "        Pip Environment Fix Tool"
echo "======================================"
echo ""
echo "1. Fix pip.conf"
echo "2. Add python alias to .bashrc"
echo "3. Fix common pip problems"
echo "4. Check for common pip issues"
echo "5. Run all fixes"
echo "0. Exit"
read -p "Choose an option: " opt

case $opt in
    1) fix_pip_conf ;;
    2) add_python_alias ;;
    3) fix_pip_problems ;;
    4) check_common_pip_issues ;;
    5)
        fix_pip_conf
        add_python_alias
        fix_pip_problems
        check_common_pip_issues
        ;;
    0) echo "Bye!" ;;
    *) echo "Invalid option!" ;;
esac
