+++
date = '2025-03-18T17:00:56-05:00'
draft = false
title = 'Site Stack'
tags = ['hosting', 'blogging']
description = "A brief overview of the site's infrastructure"
type = 'post'
+++
***
Just in case anyone's curious, I figured I would detail how this site is actually configured.

The high level view of it would look something like this:

Markdown Files -> Hugo -> Nginx -> Traefik -> The Internet

But this doesn't really paint the full picture, now does it?

## Markdown and Hugo
Okay so there's this really great markup language called Markdown, *which I'm sure none of you have *ever* heard of before*. \*Cough\*

No, but seriously, Markdown is great because it has super simple rules, can be quickly converted to an aesthetic view, and is basically everywhere.
[Hugo](https://gohugo.io/) makes use of this by allowing you to write blog posts (and a ton more) in simple markdown, which it then converts into a pretty version based on the themes that you install. I'm using the [Gokarna](https://themes.gohugo.io/themes/gokarna/) theme, by the way.

This is what's called a *Static Site Generator*, which is just a fancy name for a program that generates a website that isn't super interactable (like a blog!).
These static sites can be really easily hosted, as they are pretty much just a collection of HTML and CSS files. No need for React here.

Once these files are built from the source markdown, it's then ready to be handed over to my web host, Nginx.

## Nginx
There's really not a whole lot to say about Nginx. It's one of the most ubiquitous web servers today, not least due to its reliability, scalability, and overall ease of use and flexibility.

The one thing to note about Nginx is that I have it running in a docker container. Basically, I just copy the static files from Hugo, pass them to the right directory in the Nginx docker container, and tell it what port to run the server on.

If you want more details on how Hugo and Nginx cooperate, take a peek at this site's [github page](https://www.github.com/LordHerdier/www), with attention to the Dockerfile.

## Traefik
*Pronounced Traffic*

Talk about a service that is absolutely integral to all of the websites and services that I host. Traefik is what's called a *Reverse Proxy*. Basically, it's a service that I expose to the internet and have it do all the routing to all of my other services.

It does this by examining the URL that you navigated to it with. For example, let's say I have both charlotte.whittleman.net and tony.whittleman.net both pointing to my traefik server in my DNS configuration (like Cloudflare). Both of these websites are hosted on seperate machines on my local network, but traefik will see which one a user is trying to reach, connect to the server itself, then forward the site data to the user. Neat right?

Another benefit of Traefik is that it provides all your sites with TLS Certificates (aka the things that make your site use https rather than http). Cool right?

## Putting it all together
While this is the basic information on the services that this site uses, there's quite a bit more configuration that goes on in the background that I haven't mentioned.
The biggest piece of it being the CI/CD pipeline to automatically update the website after the [github repo](https://www.github.com/LordHerdier/www) is updated.

Basically, whenever I push an update to the repo, Github will send a POST request to a *web hook* that I have running on my local server. When the hook receives the update signal, it will then pull the changed files from the repository, re-build the website with Hugo, then automatically update the docker container running the site.

There are quite a few ways to implement webhooks, but I like to use [Komodo](https://komo.do/), a fully featured build and deployment solution. It's just a nice interface to host all of my services and easily update them with hooks and whatnot. It's seriously powerful, and definitely worth a look into if you're in the DevOps realm.

## Conclusion
While this is definitely more work than, say, using Github Pages and their automatic build tools for Hugo, I think it's worth hosting your personal website on your own, especially if you're interested in self-hosting. 

I might go into more detail for some of these services in a later post, but for now this has been the basics of my web stack. If you are interested in replicating it, I encourage you! Take a peek at my github repository and steal all you like.
