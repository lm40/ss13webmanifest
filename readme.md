# SS13 Web Manifest (Java)
This project is an open source program which hooks over network with BYOND to allow users to view the manifest from a website.
## Ownership
Most of the java code is written by Demintika, however I'm essentially publishing it for them as they do not wish to be associated with it. Any inquiries or questions may be run through me, as I will be responsible for maintaining this repository.
## Requirements
Java JDK 11 or greater
## Arguments
All arguments are formatted as such: --arg=value, so you would run: java -jar manifest-0.1.1.jar --arg1=value1 --arg2=value2... etc
server.port (default: 4583): The port on which the web manifest is hosted
socket.host: The hostname of the SS13 server to get the manifest from
socket.port: The port on which to get the manifest from the SS13 server
ttl (default: 60000): How long the web manifest should use the cache before getting a new manifest from the SS13 server in milliseconds.
## Usage
This will be best used in combination with a program such as apache or nginx to reverse proxy to the app, however if you would like to simply use this on it's own, pointing a domain at the correct IP address and setting the server.port to 80 will allow users to view the website under HTTP

Windows:
Run build.bat to build with gradle.
The built jar will go to ./build/lib/manifest-VERSION.jar

To run as service:
Update ./misc/windows/WinSW.xml, replace PATHTO with the path to this repository, replace SS13HOSTNAME with the IP or domain/hostname of your SS13 server, and SS13PORT with the port for your SS13server, as well as make any modifications you need to, such as adding more arguments.
Run install.bat

Linux:
Run build.sh to build with gradle
The built jar will go to ./build/lib/manifest-VERSION.jar

To run as service(Systemd enabled systems only):
Update ./misc/linux/webmanifest.service, replace PATHTO with the path to this repository, replace SS13HOSTNAME with the IP or domain/hostname of your SS13 server, and SS13PORT with the port for your SS13server, as well as make any modifications you need to, such as adding more arguments.
For user install: run user_install.sh as the user you want to install the service as.
For root/system install: run sudo root_install.sh

## Making this work with your ss13 code
Inside of misc/dmsrc is currently only polaris_world.dm, which contains world/Topic() code that should be functional with polaris code. You can modify this code to suit your own codebase or you can request that a new version be made. I may create one for TG codebases in the near future.