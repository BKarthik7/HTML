# Use nginx as the base image to serve static files
FROM nginx:alpine

# Copy your HTML, CSS, JS files to nginx's web directory
COPY . /usr/share/nginx/html/

# Expose port 80
EXPOSE 80

# Nginx starts automatically, so no CMD needed
