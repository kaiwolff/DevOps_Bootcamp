# Infrastructure as Code

Idea is to automate even the creation of virtual machines,.


## Ansible
We will be using ansible to perform these tasks

Ansible is what is termed agentless, meaning only the Ansible controller (aka the master ndoe) needs to have Ansible installed

- Agent nodes do not need Ansible to be installed

Setting up and Ansible Controller - Install Ansible with the following dependencies:

    - Ansible
    - Python
    - Any other packages to be used


### The Controller

This is used to run commands on the machines that are put under its' control.

- This is incredibly useful, as it allows mass updating of machines, for example

- for now a simple command is

```
ansible db -m ping
```

with `-a` flag, we can run ad-hoc commands on the command line of target VMs

 ## Yaml

 Widely used. Short for "Yet Another Markup Language"

 - extensions are usually `.yml` or `.yaml`
 - used across several applications. Ansible uses them for playbooks and they are also used by Kubernetes
 - Playbooks are scripts for implementing installations and the command line in 


 There are downsides/pitfalls to writing yamls:

 - careful with indentation


## Using playbooks to set up VMs

- To activate a playbook use `ansible-playbook [yaml file]`. This will perform the operations and give feedback

- Useful option to metion is `gather_facts` which prompts ansible to give feedback to the user.


