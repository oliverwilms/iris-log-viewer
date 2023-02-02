 [![Gitter](https://img.shields.io/badge/Available%20on-Intersystems%20Open%20Exchange-00b2a9.svg)](https://openexchange.intersystems.com/package/iris-log-viewer)
 [![Quality Gate Status](https://community.objectscriptquality.com/api/project_badges/measure?project=intersystems_iris_community%2Firis-log-viewer&metric=alert_status)](https://community.objectscriptquality.com/dashboard?id=intersystems_iris_community%2Firis-log-viewer)
 [![Reliability Rating](https://community.objectscriptquality.com/api/project_badges/measure?project=intersystems_iris_community%2Firis-log-viewer&metric=reliability_rating)](https://community.objectscriptquality.com/dashboard?id=intersystems_iris_community%2Firis-log-viewer)

# iris-log-viewer

http://localhost:52795/irisapp/irislogviewer.csp

![screenshot](https://github.com/oliverwilms/bilder/blob/main/iris-log-viewer.png)

## Description
iris-log-viewer provides an alternative to the Console Log Viewer web page available in IRIS Management Portal:
* Allows Download of messages.log
* Allows Filter based on Date and Time
* Allows Filter based on Severity Level 
* Includes a unit testing environment: sample unit tests
* Ready for embedded python development: ENV varialbes are set up, CallIn service is On, all modules in requirements.txt will be installed during docker build.

## Prerequisites
Make sure you have [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and [Docker desktop](https://www.docker.com/products/docker-desktop) installed.

## Installation 

Clone/git pull the repo into any local directory

```
$ git clone https://github.com/oliverwilms/iris-log-viewer.git
```

I run containers on AWS EC2 instance. I needed to adjust directory permission:

```
$ chmod 777 iris-log-viewer
```

Open the terminal in this directory and call the command to build and run InterSystems IRIS in container:

```
$ docker-compose up -d
```

To open IRIS Terminal do:

```
$ docker-compose exec iris iris session iris -U IRISAPP
IRISAPP>
```

To exit the terminal, do any of the following:

```
Enter HALT or H (not case-sensitive)
```

## Running unit tests

The template contains two test classes: `TestObjectScript.cls` and `TestPersistentClass.cls `

To run the unit tests we can use the Package Manager environment.

```
IRISAPP>zpm

=============================================================================
|| Welcome to the Package Manager Shell (ZPM).                             ||
|| Enter q/quit to exit the shell. Enter ?/help to view available commands ||
=============================================================================
zpm:IRISAPP>load /home/irisowner/irisdev

[IRISAPP|iris-log-viewer]       Reload START (/home/irisowner/irisdev/)
[IRISAPP|iris-log-viewer]       requirements.txt START
[IRISAPP|iris-log-viewer]       requirements.txt SUCCESS
[IRISAPP|iris-log-viewer]       Reload SUCCESS
[iris-log-viewer]       Module object refreshed.
[IRISAPP|iris-log-viewer]       Validate START
[IRISAPP|iris-log-viewer]       Validate SUCCESS
[IRISAPP|iris-log-viewer]       Compile START
[IRISAPP|iris-log-viewer]       Compile SUCCESS
[IRISAPP|iris-log-viewer]       Activate START
[IRISAPP|iris-log-viewer]       Configure START
[IRISAPP|iris-log-viewer]       Configure SUCCESS
[IRISAPP|iris-log-viewer]       Activate SUCCESS
zpm:IRISAPP>test iris-log-viewer

[IRISAPP|iris-log-viewer]       Reload START (/home/irisowner/irisdev/)
[IRISAPP|iris-log-viewer]       Reload SUCCESS
[iris-log-viewer]       Module object refreshed.
[IRISAPP|iris-log-viewer]       Validate START
[IRISAPP|iris-log-viewer]       Validate SUCCESS
[IRISAPP|iris-log-viewer]       Compile START
[IRISAPP|iris-log-viewer]       Compile SUCCESS
[IRISAPP|iris-log-viewer]       Activate START
[IRISAPP|iris-log-viewer]       Configure START
[IRISAPP|iris-log-viewer]       Configure SUCCESS
[IRISAPP|iris-log-viewer]       Activate SUCCESS
[IRISAPP|iris-log-viewer]       Test START
Use the following URL to view the result:
http://172.28.0.2:52773/csp/sys/%25UnitTest.Portal.Indices.cls?Index=1&$NAMESPACE=IRISAPP
All PASSED

[IRISAPP|iris-log-viewer]       Test SUCCESS
zpm:IRISAPP>
```

In case of test errors, you can find more details back in the UnitTest portal, which can be easily opened via ObjectScript menu in VSCode:

![vscvode unittest](https://user-images.githubusercontent.com/2781759/152678943-7d9d9696-e26a-449f-b1d7-f924528c8e3a.png)

## What else is inside the repository

### .github folder

Contains two GitHub actions workflows: 
1. `github-registry.yml` 
    Once changes pushed to the repo, the action builds the docker image on Github side and pushes the image to Github registry that can be very convenient to further cloud deployement, e.g. kubernetes.
2. `objectscript-qaulity.yml`
    with every push to master or main branch the workflow launches the repo test on objectscript issues with Objectscript Quality tool, [see the examples](https://community.objectscriptquality.com/projects?sort=-analysis_date). This works if the repo is open-source only.

Both workflows are repo agnostic: so they work with any repository where they exist.

### .vscode folder
Contains two files to setup vscode environment:

#### .vscode/settings.json

Settings file to let you immediately code in VSCode with [VSCode ObjectScript plugin](https://marketplace.visualstudio.com/items?itemName=daimor.vscode-objectscript))

#### .vscode/launch.json

Config file if you want to debug with VSCode ObjectScript

### src folder

Contains source files.
src/iris contains InterSystems IRIS Objectscript code

### tests folder
Contains unit tests for the ObjectScript classes

### dev.md

### docker-compose.yml

A docker engine helper file to manage images building and rule ports mapping an the host to container folders(volumes) mapping

### Dockerfile

The simplest dockerfile which starts IRIS and imports code from /src folder into it.
Use the related docker-compose.yml to easily setup additional parametes like port number and where you map keys and host folders.

### module.xml

IPM Module's description of the code in the repository.
It describes what is loaded with the method, how it is being tested and what apps neeed to be created, what files need to be copied.

[Read about all the files in this artilce](https://community.intersystems.com/post/dockerfile-and-friends-or-how-run-and-collaborate-objectscript-projects-intersystems-iris)
