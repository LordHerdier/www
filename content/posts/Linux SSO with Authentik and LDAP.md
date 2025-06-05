date = '2025-06-04T18:24:56-05:00'
draft = false
title = 'Linux SSO with Authentik and LDAP'
tags = ['linux','SSO','Authentik','LDAP','Guide']
description = 'Setting up single login across multiple linux machines'
type = 'post'
+++

# The Problem
In a production environment, you might have hundreds or even thousands of machines to log into. Manually adding users, setting permissions, and tweaking configs on each box? Yikes.

For two machines that might be okay, but for hundreds? No bueno.

For homelabers, you probably don’t have hundreds of different machines, but you still may have a few dozen different virtual machines that you want to synchronize logins on. If you’re already running [Authentik](https://goauthentik.io/), you already have everything you need to setup single sign on for all of your servers.

This guide will show you how to setup single sign on for all of your linux machines using Authentik and LDAP (using nslcd on the client side). This will allow you to use a single username and password to login to all of your machines. We'll also be setting up a sudoers file to allow for easy group based administration of the machines (yes, you can also use LDAP to manage your sudoers file, but that's for another guide).


# The High-Level Plan

1. Setting up the Authentik LDAP Provider
2. Create the outpost
3. Add the outpost to your docker compose file
4. Create the Linux User Group
5. Clone my [linux-sso](https://github.com/LordHerdier/ansible-ldap) repository
6. Copy the example config files and adjust them to your needs  
7. Manually apply the config files to your first machine (don't worry, we'll automate this later)
8. Test that you can login to your first machine
9. Automate with Ansible
10. Profit


## Prerequisites
1. A working Authentik instance running on docker
2. A domain that you own or have access to
3. Administrator access to the machines you want to apply SSO to
4. A working knowledge of git and the command line

***If you don’t have Authentik running and are interested in setting up SSO for not just your linux logins but for your websites as well, then check out Christian Lempa’s guide for installing and configuring Authentik [here.](https://youtu.be/N5unsATNpJk?si=WSXns2jzPNfl_wCO)***

## Step 1: Setting up the Authentik LDAP Provider

### Step 1.1: Add an LDAP service account
- Navigate to the authentik admin interface
- On the sidebar, navigate to `Directory` > `Users`
- Click `Create Service Account`
- Set the `Username` to `LDAPServiceAccount`
- Disable the checkboxes for `Create Group` and `Expiring`
- Click `Create`
- Select the `LDAPServiceAccount` user you just created
- Click `Set Password`
- Enter a password for the account
- Click `Update Password`

### Step 1.2: Create an LDAP Authentication Flow
#### Step 1.2.1: Add the password stage
- On the sidebar, navigate to `Flows and Stages` > `Stages`
- Click `Create`
- Select `password-stage`
- Enter `ldap-password-stage` as the `Name`
- Under the `Stage-specific settings` section, set `Backends` to the following:
  - `User database + standard password` enabled
  - `User database + app passwords` enabled
  - `User database + LDAP password` enabled
  - `User database + Kerberos password` disabled
- For `Configuration flow`, select `default-password-change (Change Password)`
- For `Failed attempts before cancel`, enter `5`
- Click `Create`

#### Step 1.2.2: Create the Flow
- On the sidebar, navigate to `Flows and Stages` > `Flows`
- Click `Create`
- Enter `ldap-authentication-flow` as the `Name`, `title`, and `slug`
- For `Designation`, select `Authentication`
- For `Authentication`, select `No requirement`
- Expand the `Advanced` section
- Set `Compatibility Mode` to enabled
- For `Denied Action`, select `MESSAGE_CONTINUE`
- Click `Create`

#### Step 1.2.3: Bind the stages to the flow
- Click on the flow you just created
- Click `Stage Bindings`
- Click `Create and bind Stage`
- Select `Identification Stage` as the `Stage`
- Set `Name` to `ldap-identification-stage`
- Under `Stage-specific settings`, enable `Username` and `Email` as the `User Fields`
- Set `Password Stage` to `ldap-password-stage`
- Enable the following options:
    - `Case insensitive matching`
    - `Pretend user exists`
    - `Show matched user`
- Click `Next`
- Set `Order` to 10
- Click `Create`
- Create another stage with `Create and bind stage`
- Select `User Login Stage` as the `Stage`
- Set the `Name` to `ldap-authentication-login`
- Set `Session duration` to `seconds=0`
- Set `Stay signed in offset` to `seconds=0`
- For `Network binding`, select `Bind ASN`
- for `GeoIP binding`, select `Bind Continent` (or another option if you want to be more specific)
- Click `Next`
- Set `Order` to 30
- Disable `Evaluate when flow is planned`
- Enable `Evaluate when stage is run`
- For `Invalid response behavior`, select `RETRY`
- Click `Create`

Your flow should look like this:

![Flow Diagram](/images/ldap-authentication-flow.png)

### Step 1.4: Add an LDAP Application and Provider
- On the sidebar, navigate to `Applications` > `Applications`
- Click `Create with Provider`
- Enter `LDAP` as the `Name` and `ldap` as the `Slug`
- Click `Next`
- Select `LDAP Provider` as the `Provider`
- Click `Next`
- Set `Bind Mode` to `Cached Binding` (this will speed up the binding process significantly)
- Set `Search Mode` to `Cached querying` 
- For `Bind Flow`, select `ldap-authentication-flow`
- For `Unbind Flow`, select `default-provider-invalidation-flow`
- For `Base DN`, enter the following and substitute your own values: `DC=ldap,DC=example,DC=com`
- For `Certificate`, either select `authentik Self-signed Certificate` or select your own certificate if you have one already configured
- If you need to set the range for UID numbers, set them now
- Click `Create`

## Step 2: Create the outpost
- On the sidebar, navigate to `Applications` > `Outposts`
- Click `Create`
- Enter a name for the outpost, for example `LDAP`
- For `Type`, select `LDAP`
- Select `Local Docker connection` as the `Integration`
- Select the `LDAP` application you created in Step 1.4
- Click `Create`
- On the outposts page, click `View Deployment Info` next to the outpost you just created
- Make a note of the `AUTHENTIK_HOST` and `AUTHENTIK_INSECURE` values as you will need them in the next step
- Also click `Click to copy token` under `AUTHENTIK_TOKEN` and save it as you will need it in the next step
- Click `Close`

## Step 3: Add the outpost to your docker compose file
- Navigate to the directory containing your authentik docker compose file
- Open the `docker-compose.yml` file
- Add the following to the `services` section:

```
  authentik_ldap:
    image: ghcr.io/goauthentik/ldap:latest
    # Optionally specify which networks the container should be
    # might be needed to reach the core authentik server
    # networks:
    #   - foo
    ports:
      - 389:3389
      - 636:6636
    environment:
      AUTHENTIK_HOST: <your-authentik-host>
      AUTHENTIK_INSECURE: <true-or-false>
      AUTHENTIK_TOKEN: <your-authentik-token>
```
- Save the file and restart your docker compose stack with `docker compose up -d`

## Step 4: Create the Linux User Group
- On the sidebar, navigate to `Directory` > `Groups`
- Click `Create`
- Enter a name for the group, for example `linux-users`
- Under `Attributes`, add the following (replacing the existing `{}`):
    - `loginShell: /bin/bash` (or whatever default shell you want to use)
- Click `Create`
- Click on the group you just created
- Click `Users`
- Add existing users or create new users that you want to be able to login to the linux machines

## Step 5: Clone my [linux-sso](https://github.com/LordHerdier/ansible-ldap) Repository

```bash
git clone https://github.com/LordHerdier/ansible-ldap.git
cd ansible-ldap
```

This repo contains:

* `ansible.cfg.example` (template for your Ansible config)
* `inventory.example` (sample inventory with host groups)
* `playbook-ldap-setup.yml` (client-side LDAP setup)
* `playbook-site-sudoers.yml` (deploys our standardized sudoers file)
* `templates/site-sudoers.j2.example` (Jinja2 template for sudoers)
* `files/`:
  * `common-account`
  * `common-auth`
  * `common-session`
  * `nslcd.conf`
  * `nsswitch.conf`

## Step 6: Copy and Customize the Example Config Files

Inside `ansible-ldap/files/`, you’ll find example versions of the PAM and NSS configs. Copy them into place and tweak as needed:

```bash
cp ansible.cfg.example ansible.cfg
cp inventory.example inventory
```

### 6.1: `nslcd.conf`

Open `nslcd.conf` and set:

* `uri ldap://<your-authentik-host>` → your LDAP host (or `ldaps://` if you’re feeling secure).
* `base DC=ldap,DC=example,DC=com` → your own Base DN.
* `binddn cn=<Your LDAP Service Account>,ou=users,dc=ldap,dc=example,dc=com` → the service account you created earlier.
* `bindpw <Your LDAP Service Account Password>` → set it to the Authentik service account’s password (or better yet, use a `bindpwfile`).
* Adjust the `filter passwd` so that only members of `cn=<Your Linux User Group>,ou=groups,dc=ldap,dc=example,dc=com` can log in.

### 6.2: `nsswitch.conf`

Ensure lines like these exist so `files`, `systemd`, and `ldap` can all provide user/group information:

```conf
passwd:         files systemd ldap
group:          files systemd ldap
shadow:         files systemd ldap
hosts:          files dns ldap
```

(You can drop in the rest of the file from the example if you want mirror behavior for `services`, `protocols`, etc.)

### 6.3: `common-*.d` (PAM configs)

In `common-account`, `common-auth`, and `common-session`, we basically punch in the `pam_ldap.so` lines so that PAM consults LDAP after files. A minimal example in `common-auth` might be:

```conf
# /etc/pam.d/common-auth
auth    [success=1 default=ignore]    pam_unix.so nullok_secure
auth    requisite                     pam_ldap.so use_first_pass
auth    required                      pam_deny.so
```

In `common-account`:

```conf
# /etc/pam.d/common-account
account [success=1 new_authtok_reqd=done default=ignore] pam_unix.so
account requisite                              pam_ldap.so
account required                               pam_deny.so
```

And in `common-session`:

```conf
# /etc/pam.d/common-session
session required   pam_unix.so
session optional   pam_ldap.so
```

(If your distribution’s default PAM layout differs, drop these lines into the right spots; just be sure to merge rather than wipe out everything.)
If you're not confident about the PAM configs, you can use the ones from the example file. They're the same ones I used for my own setup. Do note that they're pulled from a Debian 12 machine.

### 6.4: `site-sudoers.j2`

This Jinja2 template is what the sudo playbook uses. Populate your user and host aliases.
Feel free to add or remove whatever you need. The example in the repo includes sensible defaults.

It should end up looking something like this:

```jinja
# /etc/sudoers.d/site_sudoers (auto-generated from Jinja2)
Defaults        env_reset
Defaults        secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
Defaults        passwd_tries=3
Defaults        logfile="/var/log/sudo.log"
Defaults        log_input,log_output

User_Alias      ITADMINS    = alice, bob, carol
User_Alias      DEVELS      = dev1, dev2

Host_Alias      PROXMOXSERVERS = pve1, pve2
Host_Alias      NETSERVERS     = dns1, vpn1, proxy1
Host_Alias      GAMESERVERS    = game1, game2
Host_Alias      DEVERS         = dev1, dev2, dev3

Cmnd_Alias      PKG_MGMT     = /usr/bin/apt*, /usr/bin/yum*, /usr/bin/dnf*
Cmnd_Alias      SERVICE      = /usr/bin/systemctl*, /usr/bin/service*
Cmnd_Alias      NET_TOOLS    = /usr/bin/ifconfig*, /usr/bin/ip*, /usr/bin/ss*, /usr/bin/netstat*
Cmnd_Alias      LOGS         = /usr/bin/journalctl*, /usr/bin/tail*, /usr/bin/less*
Cmnd_Alias      DOCKER       = /usr/bin/docker*
Cmnd_Alias      SENSITIVE    = /usr/bin/passwd, /usr/bin/su, /usr/bin/ssh-keygen

ITADMINS ALL = (ALL) ALL
DEVELS   NETSERVERS = (ALL) NOPASSWD: SERVICE, LOGS
DEVELS   GAMESERVERS = (ALL) NOPASSWD: LOGS
```

Adapt user and host aliases to reflect your real server names and admin/dev accounts.


## Step 7: Manually Apply to Your First Machine

Okay, so far we’ve set up Authentik, created an LDAP service account, configured an outpost, and cloned the repo with all the configs. Now let’s test this on one box before rolling it out.

> **Warning**: This will overwrite critical system files. Back them up first. You have been warned.

1. **SSH to your target (e.g., `linux-test1`).**

   ```bash
   ssh root@linux-test1
   ```

   You may also want to copy your SSH key to the target machine if you haven't already.

   ```bash
   ssh-copy-id root@linux-test1
   ```

2. **Install the needed packages** (Debian/Ubuntu example):

   ```bash
   apt update
   apt install -y libnss-ldapd libpam-ldapd nslcd
   ```

   The installer might prompt for LDAP URIs, base DN, etc. You can skip those interactive prompts because we’re going to replace them with our config files. If you’re feeling masochistic, fill them out exactly like your `nslcd.conf` and `nsswitch.conf`.

3. **Backup existing config files**:

   ```bash
   for f in /etc/nslcd.conf /etc/nsswitch.conf /etc/pam.d/{common-account,common-auth,common-session}; do
     cp "$f" "${f}.bak.$(date +%F_%T)"
   done
   ```

4. **Copy over the custom configs** (from the Ansible repo’s `files/` directory):

   ```bash
   # On your local machine:
   scp ansible-ldap/files/nslcd.conf root@linux-test1:/etc/nslcd.conf
   scp ansible-ldap/files/nsswitch.conf root@linux-test1:/etc/nsswitch.conf
   scp ansible-ldap/files/common-account root@linux-test1:/etc/pam.d/common-account
   scp ansible-ldap/files/common-auth root@linux-test1:/etc/pam.d/common-auth
   scp ansible-ldap/files/common-session root@linux-test1:/etc/pam.d/common-session
   ```

5. **Restart `nslcd`** and make sure it’s running:

   ```bash
   systemctl restart nslcd
   systemctl status nslcd
   ```

   If it’s unhappy, check `/var/log/syslog` (or `journalctl -u nslcd`) for hints. Common pitfalls include:

   * Wrong `binddn` / `bindpw`.
   * `base DN` that doesn’t match your Authentik LDAP structure.
   * A firewall blocking port 389/636.

6. **Test LDAP connectivity**:

   ```bash
   getent passwd
   ```

   You should see local users **and** any users in the `linux-users` group from Authentik. If `getent passwd` hangs or throws errors, fix that before proceeding.

7. **Deploy the sudoers file** so that your LDAP users can get sudo privileges (if you want to try this now):

   ```bash
   mkdir -p /etc/sudoers.d
   scp ansible-ldap/templates/site-sudoers.j2 root@linux-test1:/tmp/site-sudoers.j2
   apt install -y python3-jinja2 sudo
   python3 -c "import jinja2, sys; print(jinja2.Template(open('/tmp/site-sudoers.j2').read()).render())" > /etc/sudoers.d/site_sudoers
   chmod 0440 /etc/sudoers.d/site_sudoers
   visudo -c
   ```

   (Yeah, this is basically what the Ansible playbook will do for you later.)
   

## Step 8: Test Your First Machine

1. **Log out of your root session**:

   ```bash
   exit
   ```

2. **SSH in as an LDAP user** (e.g., `bob@linux-test1`):

   ```bash
   ssh bob@linux-test1
   ```

   If everything worked, you should land in a shell prompt as `bob`. Sweet relief.

3. **Try sudo** (if you put `bob` in the `linux-users` group and updated your sudoers template so that `ITADMINS` or a development alias includes `bob`):

   ```bash
   sudo -l
   sudo whoami
   ```

   If that’s all clean, you have successfully logged in and elevated privileges using LDAP credentials. Take a shot of your favorite beverage (responsibly).


## Step 9: Automate with Ansible

Now comes the part where you stop doing all these copy-and-pastes and shout curses at SSH.

0. **Install Ansible** (if you haven't already)

    First, install pipx to actually install ansible.

    ```bash
    sudo apt update
    sudo apt install pipx
    pipx ensurepath
    sudo pipx ensurepath --global # optional to allow pipx actions with --global argument
    ```

    Then, install ansible.

    ```bash
    pipx install --include-deps ansible
    ```

1. **Customize `ansible.cfg`** (in the cloned `ansible-ldap` directory):

   ```ini
   [defaults]
   inventory = ./inventory
   private_key_file = ~/.ssh/id_ed25519   # or whatever key you already loaded
   host_key_checking = False
   ```

2. **Edit `inventory`** (formerly `inventory.example`) to list your hosts, separated by groups. For example:

   ```ini
   [netservers]
   linux-test1 ansible_host=192.168.1.10
   linux-test2 ansible_host=192.168.1.11

   [devservers]
   dev-01 ansible_host=192.168.1.20

   [proxmoxservers]
   pve1 ansible_host=192.168.1.100
   pve2 ansible_host=192.168.1.101
   ```

3. **Tweak `templates/site-sudoers.j2`** to list your actual usernames and host aliases (so Ansible can template them correctly).

4. **Verify connectivity**:

   ```bash
   ansible all -m ping
   ```

   If you see “pong” from each host, Ansible is golden.

5. **Run the LDAP setup playbook**:

   ```bash
   ansible-playbook playbook-ldap-setup.yml
   ```

   This playbook will:

   * Install and configure `libpam-ldapd`, `libnss-ldapd`, `nslcd`.
   * Back up any existing `nsswitch.conf` or PAM files.
   * Deploy your custom `nslcd.conf`, `nsswitch.conf`, and PAM snippets.
   * Start (and enable) the `nslcd` service.

   If you only want to target a subset of hosts (e.g., the netservers), do:

   ```bash
   ansible-playbook playbook-ldap-setup.yml --limit netservers
   ```

6. **Run the sudoers playbook**:

   ```bash
   ansible-playbook playbook-site-sudoers.yml
   ```

   This will:

   * Install (if needed) the `sudo` package.
   * Jinja-render `templates/site-sudoers.j2` → `/etc/sudoers.d/site_sudoers`.
   * Enforce `0440` permissions.
   * Validate syntax with `visudo -c`.

7. **Reboot or restart services** (if needed). Typically, you don’t have to reboot after a PAM/NSS reconfiguration. A logout/login (or a quick `systemctl restart sshd nslcd`) is enough.

8. **Verify on each host**:

   ```bash
   ansible all -m shell -a "getent passwd | grep <some-ldap-user>"
   ansible all -m shell -a "sudo ls /root"
   ```

   If these both work across your entire fleet, you can lean back and crack open a cold one.

## Step 10: Profit (and Keep an Eye on It)

You should now be able to do the following on any machine in your inventory:

1. SSH in as an LDAP-managed user (e.g., `alice`, `bob`, etc.).
2. `sudo` if your group/alias is allowed.
3. Remove the constant worry of “did I remember to create that user on `linux-test-47`?”

### A Few Parting Tips

* **Password Changes**: If an LDAP user changes their password in Authentik, it should immediately propagate to all Linux boxes (assuming your flow is working).
* **Group Management**: Add or remove users from the `linux-users` group in Authentik to control who can log in.
* **Sudoers Tweaks**: If you need a new command alias or want to tweak logging, just update `templates/site-sudoers.j2` and re-run `ansible-playbook playbook-site-sudoers.yml`.
* **Locking Down**: If you want to restrict SSH to certain groups only, add in an `/etc/ssh/sshd_config` `AllowGroups linux-users` line (and restart `sshd`).

## Conclusion

Setting up Linux SSO with Authentik + LDAP may feel like wrangling a herd of caffeinated cats at first, but once you’ve got the outpost, configs, and Ansible playbooks in place, adding a fresh machine to your homelab—or your data center-becomes just a bit easier.

Now go ahead: try to break it, file an issue, or brag to your colleagues that you no longer have to manually manage local `/etc/passwd` files on twenty boxes. You earned it.

Happy authenticating!
