# Nginx + PHP + OCI8 (alpine)

This is a Web Server image to easily build an Oracle environment for test purposes.

## How to build

- Download the official [Oracle Database Client](https://www.oracle.com/database/technologies/oracle19c-linux-downloads.html) (home) and [SDK](https://www.oracle.com/database/technologies/instant-client/downloads.html) installer
- Put the archive in the `installer` directory (separate instantclient and sdk folder)
- Execute `docker run up -d` It will create the image and install Oracle Instant Client on it. it can take some time.   
