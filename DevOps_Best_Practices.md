# Best Practices

- Start with pseudocode. This should describe the desired outcomes concisely
- List anticipated requirements for files (e.g. need config file for nginx)

**An example: The Requirements for automated start**
```
- Create a file for nginx.conf on localhost
- create file for mongod.conf
-provision.sh for app
- provision.sh for db
-set up environment variable once db is up
- seed db
- add dependencies
```

tackle this process one step at a time. Isolate problems and tackle one at a time.