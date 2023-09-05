#!/bin/bash

SSH_DIR="$HOME/.ssh"
ALIAS_DIR="$SSH_DIR/aliases"
METADATA="$ALIAS_DIR/metadata.txt"

# Initialize if not exists
if [ ! -d "$ALIAS_DIR" ]; then
    mkdir -p "$ALIAS_DIR"
fi

if [ ! -f "$METADATA" ]; then
    touch "$METADATA"
fi

# Check the operating system
if [[ "$OSTYPE" == "darwin"* ]]; then
    SED_INPLACE="-i ''"
else
    SED_INPLACE="-i"
fi

# Create SSH key
create_ssh() {
    alias_name=$1
    repo_url=$2

    ssh-keygen -t rsa -b 4096 -f "$ALIAS_DIR/$alias_name" -N ""

    {
        echo "Host $alias_name"
        echo "  HostName $(echo $repo_url | awk -F'[:/]' '{print $3}')"
        echo "  IdentityFile $ALIAS_DIR/$alias_name"
    } >> "$SSH_DIR/config"

    echo "$alias_name=$repo_url" >> $METADATA
}

# Delete alias but keep SSH keys
delete_alias() {
    alias_name=$1
    if [ -z "$alias_name" ]; then
        echo "Alias name is empty. Cannot proceed with deletion."
        return
    fi
    echo "Deleting alias $alias_name from metadata and SSH config."

    # Delete the line with the corresponding alias in the metadata file
    sed $SED_INPLACE "/^$alias_name=/d" $METADATA

    # Delete the corresponding entry in the SSH config
    sed $SED_INPLACE "/Host $alias_name/,+2d" "$SSH_DIR/config"
}

# Delete alias and SSH keys
clean_alias() {
    alias_name=$1
    if [ -z "$alias_name" ]; then
        echo "Alias name is empty. Cannot proceed with cleaning."
        return
    fi
    echo "Cleaning alias $alias_name from metadata, SSH config, and deleting SSH keys."

    delete_alias $alias_name  # Remove from metadata and SSH config

    if [ -f "$ALIAS_DIR/$alias_name" ] && [ -f "$ALIAS_DIR/$alias_name.pub" ]; then  # Check if SSH keys exist
        rm "$ALIAS_DIR/$alias_name" "$ALIAS_DIR/$alias_name.pub"  # Remove SSH keys
    else
        echo "SSH keys for $alias_name not found. They may have already been cleaned."
    fi
}


# Show public key
show_public_key() {
    alias_name=$1
    cat "$ALIAS_DIR/$alias_name.pub"
}

# Clone repo
clone_repo() {
  alias_name=$1
  dir=$2
 
  # Retrieve the repo URL from metadata using alias
  repo_url=$(grep "^$alias_name=" $METADATA | cut -d= -f2)

  if [ -z "$repo_url" ]; then
    echo "Alias does not exist."
    exit 1
  fi

  # Ensure directory exists
  mkdir -p "$dir"

  # Clone
  GIT_SSH_COMMAND="ssh -i $ALIAS_DIR/$alias_name" git clone $repo_url $dir
}


# List all aliases
list_aliases() {
    echo "Aliases and associated repos:"
    cat $METADATA
}

# Main execution
command=$1

case $command in
    "create")
        create_ssh $3 $5
        ;;
    "delete")
        delete_alias $3
        ;;
    "clean")
        clean_alias $3
        ;;
    "publickey")
        show_public_key $3
        ;;
    "clone")
        clone_repo $3 $5
        ;;
    "list")
        list_aliases
        ;;
    *)
        echo "Invalid command."
        echo "Usage:"
        echo "  sh sgh.sh create --alias project-alias --repo ssh://[url]"
        echo "  sh sgh.sh delete --alias project-alias"
        echo "  sh sgh.sh clean --alias project-alias"
        echo "  sh sgh.sh publickey --alias project-alias"
        echo "  sh sgh.sh clone --alias project-alias --dir ./[directory]"
        echo "  sh sgh.sh list"
        ;;
esac
