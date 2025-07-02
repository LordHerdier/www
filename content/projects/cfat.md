+++
date = '2025-06-18T16:14-05:00'
draft = false
title = 'CFAT'
tags = ['testing','automation','tools']
description = 'Custom File Allocation Table (FAT) Implementation'
type = 'post'
+++

CFAT File System: Because Re-inventing the Wheel Is Educational.

Check out the [repo](https://github.com/LordHerdier/CFAT) for more details.

Here’s the scoop:

1. **What It Does**

   * Full CRUD on files and directories (create, read, update, delete), because obviously you need that.
   * Bash around in an interactive shell: `ls`, `cd`, `tree`, `cat`, `rm`, `mkdir`—all your favorite file-system rituals.
   * Slice out files with `extract` or mount the whole thing to a folder and pretend it’s “real.”

2. **How to Get It**

   * `sudo apt-get install libfuse-dev pkg-config` on Debian-y systems.
   * `make` (or `gcc cfs.c -o cfs \`pkg-config fuse --cflags --libs\`\` if you’re feeling old-school).

3. **How to Use It**

   * **Create**: `./cfs -f mydisk.CFAT -c`
   * **List**: `./cfs -f mydisk.CFAT -l`
   * **Add**: `./cfs -f mydisk.CFAT -a report.pdf -i /docs/`
   * **Mount**: `./cfs -f mydisk.CFAT -m /mnt/fat` …then `fusermount -u /mnt/fat` when you’re done janking around.
   * **Interactive**: `./cfs -f mydisk.CFAT -I`—type `help` to see all the shady commands.

4. **The Inevitable Caveats**

   * 11-char filename limit (yes, really).
   * Large files (>131 KB) might trigger undocumented gremlins.
   * Editing via Vim/Emacs can segfault; Nano is your best friend.
   * “Transport endpoint is not connected”? That’s FUSE yelling at you—just rerun `fusermount -d` and remount.

In short, CFAT is absurdly instructive, mildly stable, and totally not where you should archive your thesis. Proceed at your own peril—and enjoy the ride through user-space madness.
