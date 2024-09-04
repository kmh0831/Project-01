#!/bin/bash
yum install -y httpd
systemctl start httpd
echo "<h1>Hello SeoulRegion - Websrv</h1>" > /var/www/html/index.html