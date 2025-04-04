+++
date = '2025-04-04T14:42:07-05:00'
draft = false
title = 'Sharing Services with Pangolin'
tags = ['Homelab','Proxy','Hosting']
description = 'Manage access to your services with Pangolin'
type = 'post'
+++
***
*Note: This is an overview of Pangolin and its use cases, and not a tutorial in setting up a Pangolin instance. If you're interested in seeing a tutorial, let me know!*

So you've gotten yourself setup with a new service and you're looking to expose it to the internet for your friends, family, and public to use. Now, you could expose it directly to the internet for everyone to access, but then you have to worry about port conflicts, security vulnerabilities, TLS encryption, and possibly even your ISP blocking the port if you're on a home internet connection.

Maybe you've heard of Traefik, NGINX proxy manager, swag, or any of the other reverse proxy solutions that will take care of automatic TLS certificate generation, as well as handling routing and load balancing to your servers. These reverse proxies let you expose just one/two ports (usually 80/443), then route *all* of your user traffic to your services based on the url that they connect with. While reverse proxies are fantastic, they don't solve the issue of ISPs blocking ports, or the potential security issue of exposing your services directly on your server's ip address.

So what's the solution? Enter: **Pangolin**, a proxy server, VPN server, and platform identity handler all rolled into one.

![Pangolin Logo Banner](/images/pangolin2.png)


>Pangolin is a self-hosted tunneled reverse proxy server with identity and access control, designed to securely expose private resources on distributed networks. Acting as a central hub, it connects isolated networks — even those behind restrictive firewalls — through encrypted tunnels, enabling easy access to remote services without opening ports. 

-[Pangolin's Github](https://github.com/fosrl/pangolin)

# The Pangolin Edge: Beyond Traditional Proxies

If you have setup a traditional reverse proxy server before, you know they can be pretty involved to setup and configure, especially while keeping security in mind. Generating TLS certificates so your browser gets that *sweet, sweet* HTTPS lock, configuring Crowdsec to secure against potential attackers, to managing Docker/WireGuard networks to make sure your service's data stays private - There's a lot to manage if you're not already deep in the hosting world. That's where Pangolin comes in, not as an average proxy, but as a Swiss Army Knife of network access.

### What makes Pangolin so different?
- **Tunneled Connectivity**: With its custom user space WireGuard client (Newt) and support for any WireGuard client, Pangolin creates secure, encrypted tunnels that let you expose private resources _without_ opening ports. Say goodbye to firewall punching and hello to effortless, site-to-site connectivity.
- **Integrated Identity Management**: Want to make sure only your friends can read your blog posts? Maybe you're hosting a service that doesn't have its own authentication? Pangolin makes it easy to manage who can access what with built-in authentication. Define granular access rules—by IP, URL, or even temporary self-destructing share links—and let two-factor authentication (with TOTP and backup codes) do its thing.
- **All-In-One Platform:** Super simple to deploy and configure, with flexibility if you want to expand beyond the standard. Pangolin is built on Traefik, WireGuard, and Crowdsec to securely deploy your services to the public.
- **Ease of Management:** Pangolin's web-ui is among the best I have seen out of all the software in the open source self-hosting community. It's modern, while still offering the flexibility needed to quickly manage your deployments.

### How does it work?
1. **Deploy the Central Server:**  
    Run the Docker Compose stack on a cloud provider or VPS. Point your domain to the server, configure your settings, and you're golden.
2. **Connect Your Private Sites:**  
    Use Newt or any WireGuard client to establish secure, encrypted tunnels from your private sites to the central server.
3. **Expose and Control Access:**  
    Add your resources to Pangolin, set up those nifty access control rules, and boom—secure remote access without a sweat.

### Similar Projects 
- **Cloudflare Tunnels:** A similar approach to proxying private resources securely, but Pangolin is a self-hosted alternative, giving you full control over your infrastructure.
- **Authentik and Authelia**: These projects inspired Pangolin’s centralized authentication system for proxies, enabling robust user and role management.
-[Pangolin's Github](https://github.com/fosrl/pangolin#similar-projects-and-inspirations)

# Usage Photos

![Pangolin Home Screen](/images/pangolin1.png)

![Pangolin Collage](/images/pangolin3.png)