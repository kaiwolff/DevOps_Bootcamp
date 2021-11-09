# Useful Linux Commands

- Identify machine : `uname` or `uname -a` for extra info
- Show current directory: `pwd`
- Show files: `ls`. To show hidden files, use `ls -a`
- Remove file `rm [filename]` or `rm -rf [filename]`. the rf flag forces the process, without asking for confirmation.
- Change directory: `cd`
- Create a new directory: `mkdir`
- List running processes: `ps` (short for process status). To show all processes, run `ps aux` or  `top`
- stop a particular process `kill process [process id]`
- `*` is a "wild card", which means everything fulfillign the previous criteria is affected e.g. `*.txt` woudl affect everythign ending in `.txt`
- change file permissions using `chmod`. Two options possible
    - use letters (+r to read, +w for write, +x to make executable)
    - numbers (this gives particular permissions to particular user groups). Easy guide to numbers [here](http://permissions-calculator.org)
- syntax is `chmod [permission_type] [filename]`
- Check permissions with `ll`
- Copy: `cp [source] [destination]`. can also use full filepaths if needed.
- to move a file or folder: `mv`
- pass one process into another process: `|`. This is also known as a pipe.


## Variables and Environment Variables
- list all environment variables: `env`
- notice that these can be interacted with using scripts or the command line
- extract a particular environment variable using `printenv [key]`
- Create a variable using `[key]=[value]`. Access using `$[key]`.
- to create an environment variable, use `export [key]=[value]`. Can access environment variables as before.
-notice that user-created environment variables are removed at the end of an ssh session. Some key variables are persistent
- to set a persistent environment variable, access one of the bash profile fioels (e.g. `.profile` in the home directory). This will require a restart of the bash shell.