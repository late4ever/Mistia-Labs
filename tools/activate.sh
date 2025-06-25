#!/bin/bash

# This script sets up project-specific aliases and functions,
# and also activates the associated Python virtual environment.
# Source this script from your project root: `source tools/activate.sh`

# Determine the absolute path to the current directory (where this script resides)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "Activating Mistia Labs project environment..."

# --- BEGIN: Virtual Environment Activation ---
if [ -f "$HOME/ansible-env/bin/activate" ]; then
    source "$HOME/ansible-env/bin/activate"
    export PS1="(Mistia-Labs) $_OLD_VIRTUAL_PS1"
    echo "Ansible virtual environment activated."
else
    echo "Warning: Ansible virtual environment not found at $HOME/ansible-env. Please create it or adjust path."
fi
# --- END: Virtual Environment Activation ---

# Define your aliases
alias ap='ansible-playbook'

# Define a function for your main playbook
function nexus_deploy() {
  local original_dir=$(pwd)
  cd "$PROJECT_ROOT/ansible/mistia-nexus" || { echo "Error: Could not change to project directory"; return 1; }
  echo "Running deploy-services.yml from $(pwd)"
  ansible-playbook deploy-services.yml "$@"
  cd "$original_dir"
}

# Define a function for editing or creating secrets
function nexus_vault() {
  local original_dir=$(pwd)
  cd "$PROJECT_ROOT/ansible/mistia-nexus" || { echo "Error: Could not change to project directory"; return 1; }
  
  local secrets_file="secrets.yml"

  if [ -f "$secrets_file" ]; then
    echo "Opening existing secrets file: $(pwd)/$secrets_file"
    ansible-vault edit "$secrets_file"
  else
    echo "Creating new secrets file: $(pwd)/$secrets_file"
    ansible-vault create "$secrets_file"
  fi

  cd "$original_dir"
}

# Export a variable to indicate the environment is active (optional)
export MISTIA_LABS_ENV_ACTIVE=true

echo "Aliases 'ap' and functions 'nexus_deploy', 'nexus_vault' are now available."
