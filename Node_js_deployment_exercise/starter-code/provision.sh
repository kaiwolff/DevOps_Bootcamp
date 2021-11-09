#!/bin/bash

#start with updating
sudo apt-get update -y


#install all requirements
sudo apt-get install nginx -y
sudo apt-get install python-software-properties -y
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
sudo apt-get install nodejs -y
sudo npm install pm2 -g
sudo apt-get upgrade -y

#should now have all prerequisites installed, time to change directory to the app directory and run the npm commands to install and run the app
cd ~app/app

npm install
(npm run start&) 

