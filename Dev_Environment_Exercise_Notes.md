# Bootcamp Day 2 - Dev Environment Exercise

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

However we also need to automate 