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
echo "4. Run all"
echo "0. Exit"
read -p "Choose an option: " opt

case $opt in
    1) fix_pip_conf ;;
    2) add_python_alias ;;
    3) fix_pip_problems ;;
    4)
        fix_pip_conf
        add_python_alias
        fix_pip_problems
        ;;
    0) echo "Bye!" ;;
    *) echo "Invalid option!" ;;
esac
