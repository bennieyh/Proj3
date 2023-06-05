#!/bin/bash

yum update -y
yum install git -y
yum install httpd -y
systemctl start httpd
systemctl enable httpd

cd /var/www/html/

# Clone the repository
git clone https://github.com/LexJacob/Proj3.git .

# Move the index.html file to the root directory
mv -v /var/www/html/webpage/index.html /var/www/html/index.html

# Copy all the assets and webpages to the root directory
cp -r /var/www/html/webpage/* /var/www/html/

# Remove the .git folder
rm -rf /var/www/html/.git

systemctl restart httpd
