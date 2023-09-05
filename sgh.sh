#!/bin/bash

# ----------------------------------------------------------------------------------
# sgh - Server Git Helper
#
# Author  : Farhan Israq
# Email   : farhan@rocketfry.com
# Homepage: https://rocketfry.com
#
# Copyright (c) 2023 Farhan Israq
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
# ----------------------------------------------------------------------------------

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


# List all aliases
list_aliases() {
    echo "Aliases and associated repos:"
    cat $METADATA
}


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
    if [ -z "$alias_name" ]; then
        echo "Alias name is empty. Cannot proceed with showing public key."
        return
    fi
    cat "$ALIAS_DIR/$alias_name.pub"
}


# Clone repo
clone_repo() {
  alias_name=$1
  dir=$2

  if [ -z "$alias_name" ]; then
    echo "Alias name is empty. Cannot proceed with cloning."
    return
  fi

  # Retrieve the repo URL from metadata using alias
  repo_url=$(grep "^$alias_name=" $METADATA | cut -d= -f2)

  if [ -z "$repo_url" ]; then
    echo "Alias does not exist."
    exit 1
  fi

  # Check if --dir option is provided
  if [ -z "$dir" ]; then
    echo "Directory not specified. Using current directory."
    dir="."
  fi

  # Ensure directory exists
  mkdir -p "$dir"

  # Clone
  GIT_SSH_COMMAND="ssh -i $ALIAS_DIR/$alias_name" git clone $repo_url $dir
}


# Pull repo
pull_repo() {
  alias_name=$1
  branch_name=$2
  remote_name=$3

  if [ -z "$alias_name" ]; then
    echo "Alias name is empty. Cannot proceed with pulling."
    return
  fi

  # Retrieve the repo URL from metadata using alias
  repo_url=$(grep "^$alias_name=" $METADATA | cut -d= -f2)

  if [ -z "$repo_url" ]; then
    echo "Alias does not exist."
    exit 1
  fi

  # Check if --branch option is provided
  if [ -z "$branch_name" ]; then
    echo "Branch not specified. Using 'main' as default."
    branch_name="main"
  fi

  # Check if --remote option is provided
  if [ -z "$remote_name" ]; then
    echo "Remote not specified. Using 'origin' as default."
    remote_name="origin"
  fi

  # Pull
  GIT_SSH_COMMAND="ssh -i $ALIAS_DIR/$alias_name" git pull $remote_name $branch_name
}


# Run any git command with ssh profile
run_git_command() {
  alias_name=$1
  shift 1  # Shift arguments to get rid of the alias_name

  # Retrieve the repo URL from metadata using alias
  repo_url=$(grep "^$alias_name=" $METADATA | cut -d= -f2)

  if [ -z "$repo_url" ]; then
    echo "Alias does not exist."
    exit 1
  fi

  # Run the git command
  git_command="GIT_SSH_COMMAND=\"ssh -i $ALIAS_DIR/$alias_name\" git $@"
  eval $git_command
}



# Main execution
command=$1

case $command in
    "list")
        list_aliases
        ;;
    "create")
        create_ssh $3 $5
        ;;
    "publickey")
        show_public_key $3
        ;;
    "delete")
        delete_alias $3
        ;;
    "clean")
        clean_alias $3
        ;;
    "clone")
        clone_repo $3 $5
        ;;
    "pull")
        pull_repo $3 $5 $7
        ;;
    "exec")
        run_git_command $3 "${@:4}"
        ;;
    *)
        echo "Invalid command."
        echo "Usage:"
        echo "  ~/sgh list"
        echo "  ~/sgh create --alias [example-alias] --repo [url]"
        echo "  ~/sgh delete --alias [example-alias]"
        echo "  ~/sgh clean --alias [example-alias]"
        echo "  ~/sgh publickey --alias [example-alias]"
        echo "  ~/sgh clone --alias [example-alias] --dir ./[directory]"
        echo "  ~/sgh pull --alias [example-alias] --branch [example-branch] --remote [example-origin]"
        echo "  ~/sgh exec --alias [example-alias] [raw git commands]"
        ;;
esac
