# Weatherapp

I tried to create the whole application in 2 ways. I used ubuntu as os functionality. 

 * Building the application locally
 * Building the application in cloud  
 
Two scripts should be executed by anyone who wishes to use the application on a local or cloud platform (One shell script and one ansible-playbook command). He needs to run the scripts in his local or cloud Ubuntu platforms.   

The whole task is divided into 4 parts.

## build docker image and run docker image under local host

The key challenge was to use containerization to link the frontend and backend code bases. In order to construct a docker image, I tried to make two build files (one for the frontend and another for the backend).

 ### frontend image build
 
Version conflicts were a difficulty I encountered when executing this build file. It's possible that the js version was out of sync with the system's other components. In order to make the current version compatible with the other entities, I defined an environment variable "openssl-legacy-provider" in the build file. The remaining settings are generally similar. Here is my frontend image buildfile. This Dockerfile should be kept under /frontend location.
 
 FROM node:latest

 RUN mkdir -p /usr/src/app/frontend
 
 WORKDIR /usr/src/app/frontend
 
 ADD . /usr/src/app/frontend
 
 RUN npm install
 
 ENV NODE_OPTIONS=--openssl-legacy-provider
 
 EXPOSE 8000

 CMD [ "npm", "run", "start" ]
 
 ### backend image build
 
Building the backend image went without any problems for me. The standard FROM, run, expose, CMD building. Below is the Dockerfile for the backend image. This Dockerfile should be kept under /backend location. 
 
 FROM node:latest

 RUN mkdir -p /usr/src/app/backend
 
 WORKDIR /usr/src/app/backend
 
 ADD . /usr/src/app/backend
 
 RUN npm install
 
 EXPOSE 9000
 
 CMD [ "npm", "run", "dev" ]

 
 ### docker compose to create image and run containers in one go 
 
A compose is set up to run both containers and generate an image with a single command. Only the "docker compose up" command needs to be executed by the user in thesame directory as the docker-compose.yml file. This section contains the yml detail. For the purpose of keeping the backup in the volume even after the removal of the images, 2 persistent volumes are assigned for the images. The creation and containarization of the image will be quicker once any user choose to rebuild it. 
 
 version: "2.2"

 services:
 
   frontend:
   
     ports:
       - 8000:8000
       
     build:
       context: ./frontend
       
     volumes:
       - frontend-volume:/usr/src/app/frontend
 
   backend:
   
     ports:
       - 9000:9000
       
     build:
       context: ./backend
       
     volumes:
       - backend-volume:/usr/src/app/backend
 
 volumes:
   frontend-volume:
   
   backend-volume:

## tag and push images in dockerhub

In order for anyone who wants to run the application to be able to pull those images and execute them all at once, the frontend and backend images have been tagged and posted to a dockerhub repository. Here are the images:

 * mobikanu/weatherapp-backend
 * mobikanu/weatherapp-frontend

## create an ec2 instance in aws

 ### ec2 instance:

An ec2 instance is launched with below configuration. 
 
     launch formation 
     AMI: ubuntu Server22.04 LTS(HVM), SSD volume type (freetier)
          amd64 jammy image build on 2022-12-01
     instance type: t2micro
     storage: 8 gb root storage without any external ssd or hdd
  
 ### elastic ip:

Elastic ip is configured to the instance so that public ip will not change after system reboot
   

## install ansible in aws ec2 and create an ansible playbook to install and build, ship run container from docker hub
    
	### installing ansible
	
A shell script is created if anyone want to install ansible in local or cloud system. Below is the shell script detail. It is kept inside /Ansible. Script is "install_ansible_ubuntu.sh"
    
     *Update Repository
    
     sudo apt-get update
     sudo apt-add-repository -y ppa:ansible/ansible
     
     *refresh the package
     
     sudo apt-get update
     
     *install Ansible
     
     sudo apt-get install -y ansible
     
     *install dependency python
     
     sudo apt install python-pip -y
     
     *check ansible version
     
     ansible --version
	 
	 ### ship and run container from dockerhub with a single ansible playbook
	 
A ansible playbook is created to install docker, build image and run containers of the whole application in a single go. It is kept inside /Ansible. User has to run "ansible-playbook Docker_Install_image_Build_container_run.yml". This playbook made use of previously generated and dockerhub pushed tagged images(mobikanu/weatherapp-frontend & backend mobikanu/weatherapp-backend).
	 
	 - hosts: localhost
       become: true
       
       
       tasks:
       - name: install_docker
         command: apt install docker.io -y
       
       - name: start_docker
         command: systemctl enable --now docker
       
       - name: pull_image-weatherapp_frontend
         command: docker pull mobikanu/weatherapp-frontend
      
       - name: pull_image-weatherapp_backend
         command: docker pull mobikanu/weatherapp-backend
       
       - name: docker_container_run_weatherapp_frontend
         command: docker container run -d -p 8000:8000 --name frontend mobikanu/weatherapp-frontend
      
       - name: docker_container_run_weatherapp_backend
         command: docker container run -d -p 9000:9000 --name backend mobikanu/weatherapp-backend
		 

So to run the application, an user has to import and run below 2 scripts in his ubuntu system. 
 * install_ansible_ubuntu.sh
 * ansible-playbook Docker_Install_image_Build_container_run.yml
 
and run 
 ./install_ansible_ubuntu.sh
   ansible-playbook Docker_Install_image_Build_container_run.yml
 



 
