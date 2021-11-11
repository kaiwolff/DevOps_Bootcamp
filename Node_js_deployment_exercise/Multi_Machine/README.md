# How to deploy
## Tl;dr How to quickly deploy

- enter this folder on your git bash
- Type `vagrant up`. Wait for vagrant to boot and provision your VMs
- Type `vagrant ssh app` to connect to the application VM
- enter /home/app/
- type `(npm run start&)` to run the app in the background.
- type `node seeds/seed.js` to seed the database.
- You can now access the app via your browser on 192.168.10.100

## The Long Read - How the App is deployed

### The Vagrantfile
- This provides two VMs, and synchronises relevant folders
```
Vagrant.configure("2") do |config|
  config.vm.define "db" do |db|
    db.vm.box = "ubuntu/xenial64"
    db.vm.network "private_network", ip: "192.168.10.150"
    db.hostsupdater.aliases = ["database.local"]
    #pass environment/db along, which contains the config files.
    db.vm.synced_folder "environment/db", "/home/environment"
    db.vm.provision "shell", path: "environment/db/provision_db.sh", privileged: false
  end

  config.vm.define "app" do |app|
    app.vm.box = "ubuntu/xenial64"
    app.vm.network "private_network", ip: "192.168.10.100"
    app.hostsupdater.aliases = ["development.local"]
    app.vm.synced_folder "app", "/home/app"
    app.vm.synced_folder "environment/app", "/home/environment"
    app.vm.provision "shell", path: "environment/app/provision_app.sh", privileged: false
    
  end
```

- `config.vm.define` separates the instructions for the VMs
- The `app` machine will have a synced folder with the app files, and an environment folder that contains the provisioning script and a replacement default file for nginx.
- The `db` machine only has the `environment folder, containing a new config file for mongodb and the provisioning script
- After syncing the folder or folders, Vagrant will run the provisioning scripts, repeating this process for the second virtual machine

### Provisioning Scripts

- These are shell scripts that will run on the VMs to set them up to run the app
#### DB VM

```
# be careful of these keys, they will go out of date
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv D68FA50FEA312927
echo "deb https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list

sudo apt-get update -y
sudo apt-get upgrade -y

# sudo apt-get install mongodb-org=3.2.20 -y
sudo apt-get install -y mongodb-org=3.2.20 mongodb-org-server=3.2.20 mongodb-org-shell=3.2.20 mongodb-org-mongos=3.2.20 mongodb-org-tools=3.2.20

#replace mongod.conf file with one from our system

sudo rm /etc/mongod.conf
sudo ln -s /home/environment/mongod.conf /etc/mongod.conf

# if mongo is is set up correctly these will be successful
sudo systemctl restart mongod
sudo systemctl enable mongod
```
- Start by updating the machine's exisitng programmes
- Then, install `mongodb`
- Next, replace the mongod.conf file with one that will allow us to connect to the database. This was provisioned by vagrant earlier, so is a simple copy command from the synced folder
- Finally, restart and re-enable `mongod` for the changes to take effect
#### App VM

```
#!/bin/bash

#start with updating
sudo apt-get update -y
sudo apt-get upgrade -y
#install all requirements

#nginx for the web server
sudo apt-get install nginx -y

#nodejs (and prerequisite python software properties)
sudo apt-get install python-software-properties -y
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
sudo apt-get install nodejs -y

#not using pm2 at the moment
#sudo npm install pm2 -g
sudo apt-get upgrade -y

#should now have all prerequisites installed, time to change directory to the app directory and run the npm commands to install and run the app
#add new environment variable to bashrc and run source to reload it

sudo echo 'export DB_HOST="mongodb://192.168.10.150:27017/posts"' >> .bashrc
source ~/.bashrc

#replace default of nginx. this hsoudl have been provisioned into /home/environment by Vagrant
sudo rm /etc/nginx/sites-available/default
sudo cp /home/environment/default /etc/nginx/sites-available/default

sudo service nginx restart
#sudo systemctl enable nginx

#node app/app/seeds/seed.js

cd /home/app
sudo npm install
sudo npm install express
#seed the database
node seeds/seed.js

#at this point, should be able to simply run the app by sshing in and entering the npm command.

#not sure how to make this run so commented out for now
#(npm run start&) 

```

- Start by updating the machine's exisitng programmes
- Then install `nginx`, `python-software-properties`, and a specific version of `node.js`.
- Run upgrade again to make sure these are up-to-date.
- With prerequisites installed, time to set up files on the machine
- Need an environment variable to point to the `db` VM. This is done by appending the relevant command to `.bashrc` and then using the `source` command to reload the settings.
- Also need to set up nginx to be our reverse proxy. To do this, we copy our provisioned "default" file into the target location and then restart nginx.
- Now, the machines are connected and ready for us to seed the database and start the app.
