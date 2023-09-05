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

### Usage Commands

Here are some example commands to help you get started:

#### To Create an SSH Profile

```bash
~/sgh create --alias [alias-name] --repo [repo-url]
```
Example:

```bash
~/sgh create --alias sgh-example --repo git@github.com:RocketFry/server-git-helper.git
```

#### To Display the Public Key for an Alias

```bash
~/sgh publickey --alias sgh-example
```

**Note: After creating a new alias, you'll need to add its `publickey` as a `deploy key` within your GitHub or GitLab project settings.**

#### To Clone a Repository

```bash
~/sgh clone --alias sgh-example --dir ./server-git-helper-example
```

#### To Pull a Repository

```bash
~/sgh pull --alias sgh-example --branch main --remote origin
```

**Note: The `--branch` and `--remote` options are optional. If not specified, `main` will be used for the branch and `origin` for the remote.**

#### To List All Aliases

```bash
~/sgh list
```

#### To Delete an SSH Profile

```bash
~/sgh delete --alias sgh-example
```

#### To Clean an SSH Profile Along with its Associated SSH Key

```bash
~/sgh clean --alias sgh-example
```

#### To Execute Raw Git Commands

```bash
~/sgh exec --alias [alias-name] [raw git commands]
```

**Usage Examples:**

To fetch updates for an alias named `sgh-example`:

```bash
~/sgh exec --alias sgh-example fetch
```

**Important Notes:**

- **Power & Responsibility**: The `exec` command is powerful and flexible. However, it comes with the responsibility of knowing what each Git command will do, as `sgh exec` does not have built-in safeguards against potentially destructive actions.

---

And there you have it! You've now successfully set up SGH and can streamline your SSH key management across multiple Git repositories.