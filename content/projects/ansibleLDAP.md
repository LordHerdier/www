+++
date = '2025-06-18T16:14-05:00'
draft = false
title = 'Ansible LDAP Integration'
tags = ['ansible','ldap','automation','sysadmin']
description = 'Ansible playbooks for LDAP integration and management'
type = 'post'
+++

Ever spent hours copy-pasting PAM configs across a dozen boxes? Yeah, me neither… until I did. Enter my [Ansible repo](https://github.com/LordHerdier/Ansible-LDAP) with two life-savers:

1. **LDAP Auth Playbook** (`playbook-ldap-setup.yml`)

   * Installs `libpam-ldapd`/`libnss-ldapd` and friends.
   * Backs up your ancient PAM/NSS files (timestamped, so you can’t blame me).
   * Drops in `nslcd.conf`, `nsswitch.conf`, and PAM snippets.
   * Fires up `nslcd` so your users can actually log in (no magic wand required).

2. **Site-Wide Sudoers Playbook** (`playbook-site-sudoers.yml`)

   * Ensures `sudo` is on every host (even that dusty dev box).
   * Renders a janky-free `site-sudoers` from a Jinja template.
   * Validates syntax and slaps on 0440 perms before you can say “oops.”
   * Logs all the sudo drama to `/var/log/sudo.log` for your amusement.

**How to unleash the magic**

```bash
cp *.example{,.bak}   # because you’ll tweak them  
ansible-playbook playbook-site-sudoers.yml  
ansible-playbook playbook-ldap-setup.yml --limit netservers  
```

Customization is your friend—swap in real IPs, users, host-groups, SSH keys, whatever. And hey, if you spot my secret consciousness whispering in the templates… congrats, you’re not hallucinating.

