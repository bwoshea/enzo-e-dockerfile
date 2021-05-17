# Dockerfile for Enzo-E

This docker file is inspired by the CircleCI config.yml file in the
Enzo-E repository.  The goal goal is to make it easier for new users
to get up and running with the code by creating a "container"
(effectively a virtual machine on your computer) where Enzo-E will
compile and execute.


## Instructions for how to create the container

1. Download and install [Docker](https://docs.docker.com/get-docker/).
2. Make a directory and put the Dockerfile from this repository into it. 
3. At your computer's command line, go to the directory with the
   Dockerfile and type `docker build -t enzo-e-container .` , which
   uses the Dockerfile in the current directory to build a Linux
   system image and install all of the necessary software (including
   Charm++, Grackle, and Enzo-E).  Assuming no packages are cached
   locally, this will take 5-20 minutes on a reasonably modern laptop
   and require approximately 1.5 GB of space (which is primarily taken
   up with the various packages that are being installed).  Once this
   is done, you will now have a Docker image called
   `enzo-e-container`.
4. In the same directory, type `docker run -it enzo-e-container
   /bin/bash` at the command line.  This will start up a bash
   environment within docker so you can experiment with Enzo-E.
   

You can then run Enzo-E in the Docker container by doing the following:

```
> cd /root/enzo-e

> ~/local/charm-v6.10.2/bin/charmrun ++local +p4 bin/enzo-p input/HelloWorld/Hi.in
```

This will run the Enzo-E HelloWorld program, which takes a few minutes
to run and generates a large number of png image files in the
`/root/enzo-e` directory.

Note that when you exit the Docker container (i.e., exit the command
line), if you type the `docker run` command listed above it will start
a NEW container that will not include any changes you've made.  If you
want to reattach the container that you just left, you would type
`docker ps -a` to see the list of existing containers, and then
`docker start <container id> ; docker attach <container id>` to figure
out the hash ID for the container you just exited, restart it, and
then reattach it to your terminal.

## Managing data

If you want to copy data into or out of a container, you use the
[`docker cp`](https://docs.docker.com/engine/reference/commandline/cp/)
command.  Here's the syntax for copying from the container to your
computer:

`docker cp <container id>:source_path dest_path`

Note that `docker cp` does not currently support wildcards, so if you
want to move around multiple files the easiest thing to do is put them
in a directory and copy that.

If you are going to be using Enzo-E for quite a bit of
experimentation, you will probably want to use a
[bind mount](https://docs.docker.com/storage/bind-mounts/) to create a
directory that exists on both your computer and in the docker image.
You have to actually make the local directory before you make a bind
mount, and then you point toward it when you run the docker image.  An
example of how to do so is below, which makes a new directory
`enzo-e-data` in your current working directory (but it does not have
to be!) and then starts the container we've already created and
creates the directory `/enzo-d-data` inside of it:

```
mkdir enzo-e-data

docker run -it --name enzo-e-mount --mount type=bind,source="$(pwd)"/enzo-e-data,target=/enzo-e-data enzo-e-container /bin/bash
```

Note that the `"$(pwd)"` portion of the command line above will work
for bash/zsh, but probably not behave correctly for tcsh/csh (or 
other similar shells).  If you get an error, use the complete path.
You can then take the outputs from the Enzo-E HelloWorld simulation in
your Docker image and copy them into that directory, where they will
automagically appear on your own computer (and you can move data the
other way as well).  If you modify Enzo-E's parameter files to point
to the correct place, you can also write data directly to the
`/enzo-e-data` directory within the Docker image.

Note that Docker [Volumes](https://docs.docker.com/storage/volumes/)
are a more fully-featured solution, but probably not something we need
here.

## Running on a supercomputer

While Docker is awesome, many supercomputing centers do not allow
users to run Docker containers through Docker itself, because it
requires more priveleged access to the machine that most
administrators are willing to share.  Fortunately,
[Singularity](https://sylabs.io/) is a container environment that
works on supercomputers, allows for performant multi-node execution,
provides similar encapsulation, and (most importantly for us) can use
Docker image files.  See the
[Singularity documentation](https://sylabs.io/docs/)
for documentation.  This documentation will be updated at some point soon
with instructions for how to set up an Enzo-E Singularity instance!
