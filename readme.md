# SGH - Server Git Helper
Want to access multiple git projects from same server and tired of managing the project ssh aliases? Let's make it easier.

### How to Use:
First of all, copy the sgh.sh into your /home directory and you are ready to go:

1. Create a new SSH key and alias:
   ```bash
   sh sgh.sh create --alias project-alias --repo git@github.com:RocketFry/server-git-helper.git
   ```

2. Delete an alias (but not the repo):
   ```bash
   sh sgh.sh delete --alias project-alias
   ```

3. Delete an alias and associated repo files:
   ```bash
   sh sgh.sh clean --alias project-alias
   ```

4. Show the public key:
   ```bash
   sh sgh.sh publickey --alias project-alias
   ```

5. Clone a repo:
   ```bash
   sh sgh.sh clone --alias project-alias --dir ./some-directory
   ```

6. List all aliases and associated repos:
   ```bash
   sh sgh.sh list
   ```

Note: After you create a new alias, use the `publickey` command to view it, then copy it, finally add this as `deploy key` in your Github / Gitlab project settings. Now you are ready to clone or pull from your server at ease.