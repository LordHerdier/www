# syntax=docker/dockerfile:1

# Stage 1: Build the site with Hugo
FROM klakegg/hugo:ext-alpine AS builder
WORKDIR /src
COPY . .
RUN rm -rf public && mkdir public
RUN hugo --minify

# Stage 2: Serve with Nginx
FROM nginx:alpine
COPY --from=builder /src/public /usr/share/nginx/html
# Clean nginx share
RUN rm /usr/share/nginx/html/index.html
# Adjust file permissions so Nginx can read them
RUN find /usr/share/nginx/html -type d -exec chmod 755 {} \; && \
    find /usr/share/nginx/html -type f -exec chmod 644 {} \;
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
