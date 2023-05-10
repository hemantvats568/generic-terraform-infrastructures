#!/bin/bash

# Install Java
sudo yum update -y
sudo amazon-linux-extras install java-openjdk11 -y

# Download and extract Apache Tomcat
wget https://downloads.apache.org/tomcat/tomcat-9/v9.0.74/bin/apache-tomcat-9.0.74.tar.gz
tar xzf apache-tomcat-9.0.74.tar.gz
sudo mv apache-tomcat-9.0.74 /usr/local/apache-tomcat


#download and place war file in ec2 instances
aws s3 cp s3://beehyvstatebucketforinternalproject/war/helloworld.war /home/ec2-user/
sudo cp /home/ec2-user/helloworld.war /usr/local/apache-tomcat/webapps/

#start tomcat
sudo /usr/local/apache-tomcat/bin/startup.sh