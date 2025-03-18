# Charlotte's Website

Hey there! Welcome to the source code for my website. This is where the magic happens—Hugo meets Nginx in a Dockerized love affair. If you're curious, go ahead and fork, clone, or just lurk around. I offer limited support here, but feel free to ping me if you run into any hiccups.

## Getting Started

### Prerequisites
- **Docker:** Make sure you have Docker installed on your machine.
- **Basic Docker Know-how:** If you're new to Docker, there are plenty of tutorials out there. It's not rocket science, promise.

### Building the Docker Image
From the project root, run:

```bash
docker build -t hugo-nginx .
```

This command:
- Builds the Hugo site (using a multi-stage Docker build, because we like keeping things neat).
- Generates the static files in the `public` folder.
- Packages everything up with Nginx to serve your site.

### Running the Docker Container
Once the image is built, run:

```bash
docker run -d -p 80:80 hugo-nginx
```

Your site should now be up and running at [http://localhost](http://localhost). Easy peasy!

## Project Structure

Here's a quick rundown of the project directories:

```
C:.
├───archetypes
├───assets
├───content
│   └───posts
├───data
├───i18n
├───layouts
├───public
│   ├───blog
│   ├───categories
│   ├───css
│   ├───images
│   ├───js
│   └───tags
├───static
│   └───images
└───themes
    └───gokarna
```

Feel free to explore the structure and make tweaks if you're feeling creative.

## Support & Contributions

I'm not offering full-on support here, but if you run into issues or have questions, drop me a message. Contributions and constructive feedback are welcome—just keep it chill, alright?

## License

This project is open source. Do what you want with it, but please don’t come expecting a step-by-step handhold through every tiny detail.

Happy hacking, and thanks for checking it out!