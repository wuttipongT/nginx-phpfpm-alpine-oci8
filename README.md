# Nginx + PHP + OCI8 (alpine)

This is a Webserver image to easily build an Oracle environment for test purposes.

## How to build

- Download the official Instant Client (home) and SDK installer on the [oracle site](https://www.oracle.com/database/technologies/instant-client/downloads.html)
- Put the archive in the `installer` directory (separate instantclient and sdk folder)
- Execute `docker run up -d`. It will create the image and install Oracle Instant Client on it. it can take some time.   
