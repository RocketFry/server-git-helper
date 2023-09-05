# SGH (Server Git Helper)

Struggling with managing SSH aliases for multiple Git projects on the same server? SGH is here to simplify your life.

## Usage Guide

SGH (Server Git Helper) is a utility script engineered to automate the cumbersome task of juggling multiple SSH keys across various Git repositories. This guide offers a step-by-step walkthrough for initial setup and subsequent usage.

### Initial Setup

#### Option 1: Automated Setup (Recommended)

You can use `curl` or `wget` to download `sgh.sh` directly to your server's home directory. Here's how:

Using `curl`:

```bash
curl -o ~/sgh https://raw.githubusercontent.com/RocketFry/server-git-helper/main/sgh.sh
```

Or using `wget`:

```bash
wget -O ~/sgh https://raw.githubusercontent.com/RocketFry/server-git-helper/main/sgh.sh
```

Then, make the script executable:

```bash
chmod +x ~/sgh
```

#### Option 2: Manual Setup

If you prefer not to use `curl` or `wget`, you can manually copy the content as described in the original guide.

1. **Copy the `sgh.sh` Contents**: Copy the contents of `sgh.sh`, which can be obtained from its original source.

#### Step 2: Create a File in Your Server's Home Directory

SSH into your server and navigate to the home directory. Create a new file named `sgh` with the following command:

```bash
touch ~/sgh
```

#### Step 3: Open the File and Paste the Contents

Although any text editor will work, this guide uses Vim for demonstration purposes.

Open the newly created file with Vim:

```bash
vim ~/sgh
```

In Vim, press `i` to switch to **Insert Mode**. Paste the previously copied contents of the `sgh.sh` script. To save and exit:

1. Press `Esc` to leave Insert Mode.
2. Type `:wq` and hit `Enter`.

#### Step 4: Make the File Executable

Run the following command to make the script executable:

```bash
chmod +x ~/sgh
```

#### Step 5: Test the Script

You're now ready to use SGH. Here are some example commands to help you get started:

##### To Create an SSH Profile

```bash
~/sgh create --alias [alias-name] --repo [repo-url]
```
Example:

```bash
~/sgh create --alias sgh-example --repo git@github.com:RocketFry/server-git-helper.git
```

##### To Display the Public Key for an Alias

```bash
~/sgh publickey --alias sgh-example
```

**Note: After creating a new alias, you'll need to add its `publickey` as a `deploy key` within your GitHub or GitLab project settings.**

##### To Clone a Repository

```bash
~/sgh clone --alias sgh-example --dir ./server-git-helper-example
```

##### To Delete an SSH Profile

```bash
~/sgh delete --alias sgh-example
```

##### To Clean an SSH Profile Along with its Associated SSH Key

```bash
~/sgh clean --alias sgh-example
```

---

And there you have it! You've now successfully set up SGH and can streamline your SSH key management across multiple Git repositories.