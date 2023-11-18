# OODBMS-study-case
this study case will cover an implementation of a OODBMS with oracle DB.

# set the working environment

# 1. Colima Installation (optional)


For people like me with non-traditional chips like Apple's ARM chips, Colima must be installed to emulate 86x_64 chip instructions.
Once installed, run in cmd line the follwoing: colima start --arch x86_64 --memory 4

For each commands whcih will be done bellow, don't forget to add the following prefix: <Colima –ssh> .

# 2. Docker Installation

Docker is a containerization tool for creating isolated, reliable work environments. Unlike classic VMware, which has to emulate an entire operating system, Docker works via DockerDemon, which saves precious resources when deploying applications

The first step is to install docker via the link below:

https://www.docker.com/get-started/

Once the application has been installed, we have two options: 

		-we can work from the terminal using the docker command
		-we can use doker-cli (docker's graphical interface)

I'd like to make it clear that I'll be using the terminal for the rest of the explanation.

# 3.	Pull the ORACLE DB image

Once Docker has been installed, we need to Pull an Oracle image via the Docker hub (for this tutorial, I've chosen the following image (other choices are possible): https://hub.docker.com/r/gvenzl/oracle-xe ). 

CMD : docker pull gvenzl/oracle-xe

Once the image has been pulled, it must be containerized:

CMD: docker run -d -p 1521:1521 -e ORACLE_PASSWORD=<your password> -v oracle-volume:/opt/oracle/oradata gvenzl/oracle-xe -full

From now on, oracle is containerized and deployed on docker. Let's create our first schema:

		CMD : docker container list

The command should display the container with its ID.
		
Copy the id and enter the following command:

docker exec <your container ID> createAppUser <your username> <yout user password> [<your target DATABASE>]
		
		--> : the default database is XEPDB1



# 4.	DBEAVER INSTALATION

I chose DBEAVER because I'm used to it, but sql developer or beekeeper are also possible. 

Once the software is installed, create the connection as usual, and we're ready to work.
(default port: 1521 IP: localhost default DB: XEPDB1)

