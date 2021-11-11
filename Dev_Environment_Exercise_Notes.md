# Bootcamp Day 2 & 3 - Dev Environment Exercise

- Aiming to deploy Nodejs app with MongoDB database
- Will be using Monolith Architecture (aiming to be self-contained within virtual machines)
- Will be using separate VMs for app and database.

## Deployment Notes

- App will be prebuilt.
- Have already provisioned for an IP, so first step is to test the node.js app can be contactable once deployed


**To make deployment easy, need to know from devs:**


- What operating system was the app developed on?
- What software packages are being used?
- What versions?
- What testing framework was used?
- What is expected behaviour of app?
- What should the app look like once deployed?

### Environment Tests

- Env Tests written in Ruby
- Folder structure available in ```starter_code```
- Vagrantfile is present but needs to be correctly set up
- Test are contained in Rakefile. 
- "Gems" (ruby extensions) are found in Gemfile
- tests for environment found in ```sample_spec.rb```
- Tests should be run on localhost, probing the virtual machine.

#### Env packages
- npm for Node

# Testing the Dev Environment

- The tests are packaged in the ```environment/spec-tests``` subfolder of ```starter-code```

- To be able to run the tests, need the gem ```bundler```, and to the run ```bundler``` on the local host.

- Initially, creating the dev environment on the VM manually:

``` 
sudo apt-get update -y
sudo apt-get upgrade -y

sudo apt-get install nginx -y

sudo apt-get python-software-properties -y

curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -

sudo apt-get install nodejs -y

sudo npm install pm2 -g

```

To recap this:

- Start by updating the system
- Then, install nginx, python-software-properties
- usign curl, install a particular version of nodejs
- run install nodejs to install nodejs (this is prompted by the output of the curl command)
- install pm2 (this is requried by the app)
- Finally, run upgrade to make sure everything is up to date.

This should now have the correct environment running. To test this, switch to ```environment/spec-tests``` and run `rake spec` for the current test state.

It is also necessary to synchronise the app folder onto the machine, using the vagrantfile:

```
config.vm.synced_folder ".","/home/vagrant/app"
```

With the files on, time to navigate to the correct folder and use npm to install and start the app

```
cd app/app/
npm install
npm start
```

the app will now start up. However, this way will run in the foreground, which is suboptimal. Want the app to run in the background so we cna continue to interact with the shell if needed. To do this, we use:
```
(npm run start&) 
```



The next step is to automate this process, which will once again be done using a provisioning shell script (in this case `provision_app`), run via the vagrantfile.

## The Database VM

Next, want to have a separate VM to host the database.

Starting by setting up a simple VM in a separate directory. See Mongo_DB directory for this.

Initially, just assigning an IP and then workign manually.

Start by installing MongoDB:

```
# be careful of these keys, they will go out of date
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv D68FA50FEA312927
echo "deb https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list

sudo apt-get update -y
sudo apt-get upgrade -y

# sudo apt-get install mongodb-org=3.2.20 -y
sudo apt-get install -y mongodb-org=3.2.20 mongodb-org-server=3.2.20 mongodb-org-shell=3.2.20 mongodb-org-mongos=3.2.20 mongodb-org-tools=3.2.20
```

Now, let's bring mongod online:

```
sudo systemctl restart mongod
sudo systemctl enable mongod
```

check whether this is active using `systemctl status mongod`.

- Now, mongodb is running, but won't yet allow the other VM to contact it. Since the activity is constrained to our machine, we can set bindIp to `0.0.0.0`, whcih tells mongod to allow contact from anywhere.
- This is done by changing the `mongo.conf` file, located in `/etc`.

- Having done this, restart mongod and enable again.

The next step is to automate this. The installation steps are packaged into the `provision_db.sh` file.
We also want a reverse proxy to allow easier interaction with the machine.
## Reverse Proxy

**A note on reverse proxies**

- The purpose of a reverse proxy is to correctly direct requests to a particular domain to the relevant web server.
- Non-technical analogy is a diversion, providing an alternative route to a destination

- Benefits of usign a reverse proxy include:
    -Freeing up ports by handling everything through one 



### Requirements for the reverse proxy:

- Want nginx to listen to port 3000, send that traffic to default port 80
- `192.168.10.100` will then show the nodeapp homepage instead of the nginx default page

### Reverse Proxy - Execution

- Modify the nginx config file
- should be at `/etc/nginx/sites-available/default
- can either edit this or completely delete and replace with new config file.
- After that, `restart` nginx and `enable`

Commands:
```
sudo rm -rf /etc/sites-available/default
sudo nano /etc/sites-available/default

sudo systemctl restart nginx
sudo systemctl enable nginx
```

Note that `enable` allows a service to be set up again without needing to completely destroy the system.

The cleaner option is to replace the `default` file.
- Interested in the `location` block, which is used to tell nginx to forward requests to the main IP to a particular port

The `default` file is replaced with:

```
upstream nodejs {                                                                                                                                                                        server 192.168.10.100:3000;                                                                                                                                                      }                                                                                                                                                                                                                                                                                                                                                                 server {                                                                                                                                                                                 listen 80;                                                                                                                                                                       location / {                                                                                                                                                                             proxy_pass http://localhost:3000;                                                                                                                                                proxy_http_version 1.1;                                                                                                                                                          proxy_set_header Upgrade $http_upgrade;                                                                                                                                          proxy_set_header Host $host;                                                                                                                                                     proxy_cache_bypass $http_upgrade;                                                                                                                                        }                                                                                                                                                                        }  
```

This tells nginx to forward any requests to 192.168.10.100 to port 3000, which is where the app is acting.


# Automation

With all this done, we now want to automate all these steps, so that a simple `vagrant up` will set up and provision our machines and set up the reverse proxy.

To do this, we will need to replace the `mongo.conf` file on the db machine, and the `default` file on the app machine.

Ordering is important, as we need to create the environment variables first.
 For a full Readme on the automated app, enter the `Multi_Machine` directory and read the `README.md` file.