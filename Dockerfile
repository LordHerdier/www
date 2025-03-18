# syntax=docker/dockerfile:1

# Stage 1: Build the site with Hugo
FROM klakegg/hugo:ext-alpine AS builder
WORKDIR /src
# Copy all project files into the builder container
COPY . .
# Build the static site with minification (remove --minify if you prefer)
RUN hugo --minify --baseURL "https://charlotte.whittleman.net"

# Stage 2: Serve with Nginx
FROM nginx:alpine
# Copy the generated static files from the builder stage into Nginx's html directory
COPY --from=builder /src/public /usr/share/nginx/html

# Expose port 80 for the Nginx container
EXPOSE 80
# Start Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
