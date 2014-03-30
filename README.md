datt-base
============

### Introduction

A base linux image based on ubuntu:12.04-4
Supervisord, Hekad, Cron, sshd and standard build utils have been pre-installed in this image. It will serve as the base image for all the datt series of Docker images.

### Usage

##### From Docker Public Repository

    > docker pull datt/datt-base

##### Using Source


    > git clone git@github.com:dattlabs/datt-base.git
    > cd datt-base
    > docker build -t {{ user }}/{{ image-name }} .


### Login Details

Defaults (easy to later change these in an custom layer)
- root / root
- ubuntu / ubuntu

### Installed Packages

- check the dockerfile for the latest...

### Configured Services & Ports

- supervisord / -
- hekad / 5565
- crond / -
- sshd / 22

### Set local firewall:

- sudo ufw allow 5565/tcp (example only. consult your security guru for the correct setting in your environment.)
