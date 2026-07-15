#!/bin/bash
apt-get update -y
apt-get install -y nginx

cat > /var/www/html/index.html << 'HTMLEOF'
<!DOCTYPE html>
<html>
  <head><title>App 1</title></head>
  <body>
    <h1>App 1 - Status: OK</h1>
    <p>This is the AWS baseline incident simulation environment.</p>
  </body>
</html>
HTMLEOF

chown www-data:www-data /var/www/html/index.html
systemctl enable nginx
systemctl restart nginx
