+++
date = '2025-06-10T10:30:00-05:00'
draft = false
title = 'How I leaned to stop worrying and love nvim'
tags = ['nvim', 'linux', 'production', 'homelab', 'vim', 'neovim']
description = 'Why I switched to Neovim and why I love it (as an emacs user)'
type = 'post'
+++

# Neovim -- The modern text editor for the modern sysadmin

If you've been around for a while, then you've probably used your fair share of editors. From the classic `vi` to the more modern `nano`.
There are a lot of good options, especially if you're a fan of the whole GUI VSCode ecosystem.

Personally, I was a long time emacs user. I loved the extensibility and just the general feel of it.
However, I found myself wanting something a bit faster, more responsive, and more modern. Enter Neovim (and lazyvim).

## Lazyvim -- The perfect starter neovim installation

One of the things that kept me on emacs for so long was all of the customization I had done.
Who wants to start over from scratch? Not me, that's for sure. (lies, I love configuring things)

[Lazyvim](https://www.lazyvim.org/) is a preconfigured Neovim setup that is designed to be fast, responsive, and easy to use.
It's also highly customizable, so you can tweak it to your heart's content.

After enabling some basic included plugins, I was able to get a fully functional Neovim setup that felt familiar and comfortable.

## Config, config, config
One of the most important things about vim, which I'm sure all of you know, is the use of modes and efficient keybindings.

Now, as someone who uses a "non-standard" keyboard layout (Colemak, BTW), not all of the default keybindings work for me.

This is especially true for the `hjkl` keys, which are used for navigation in normal mode.
These are in such weird places on my keyboard that navigating with them is a pain.

Thankfully, Neovim has a great configuration system that allows you to remap keys to your heart's content.
Even better, someone already did the work for me and created a colemak remap for Neovim!
Check it out [here](https://github.com/theniceboy/nvim). Thanks, TheNiceBoy!

Of course, I also configured my own keybindings and tweaked other settings to my liking.
If you want to clone my config, you can find it in my Dotfiles repository [here](https://github.com/LordHerdier/dotfiles).

## Final Thoughts
At first, I really though I was going to hate Neovim (typical emacs user, right?). But honestly? It's fantastic!
The sheer number of keybinds can make it seem a bit overwhelming at first, once you get used to it, it's actually quite intuitive.
Especially with the help of which-key, which shows you the available keybindings for the current mode, automatically included with Lazyvim.

I still have a bit of configuration and learning to do, but so far, I'm really enjoying the experience.
If you haven't tried Neovim yet, I highly recommend giving it a shot!

