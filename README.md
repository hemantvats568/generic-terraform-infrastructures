# Terraform AWS Starter

### Pre-requisite:
- You must have AWS account
- To install Terraform, follow this [page](https://learn.hashicorp.com/terraform/getting-started/install)


#### Steps to follow in order to provision infra on AWS
1. Set the values in the set-env.sh for the variables:
    ```bash
   source set-env.sh
   ```
   The following variables needs to be defined in `set-env.sh`
   
| Variable | Description                                                                                          |
|----------|------------------------------------------------------------------------------------------------------|
|AWS_ACCESS_KEY_ID | Set aws access key id                                                                                |
|AWS_SECRET_ACCESS_KEY | Set aws secret access key                                                                            |
|AWS_DEFAULT_REGION | Set default region                                                                                   |
|TF_VAR_db_username | Set username for rds database                                                                        |
|TF_VAR_db_password | Set password for rds database                                                                        |
|TF_VAR_state_bucket_name | Provide bucket name **that should be unique in whole aws** in which terraform.tfstate will be stored |
|TF_VAR_state_lock_table_name | Provide dynamodb table name for the state lock to be created                                         |       

2. After setting the variables, cd to state-s3 directory and run the following commands:
   ```bash
    terraform init
    terraform plan
    terraform apply
   ```
   this will set up a remote s3 bucket(which will be used to store state of the project) and a dynamodb table(which will have state-lock) for the project.
3. Now, cd to root project directory and set the names for s3 bucket and dynamodb state lock in **backend.tf**.
4. All the initial requirements are done, now it's time to fill the values in **terraform.tfvars** file. Description for some of the variables are mentioned below:

   a. vpc
      ```
      vpc_cidr_block: vpc cidr block defines the cidr block of ip addresses for all resources that will be spun up in VPC.  
      eg: 10.0.0.0/16
      ```
   b. Subnet groups
      ```
      subnet_names: Comma separated list of names of the subnet groups that you want to create.
      subnet_zones: It's a map of subnet groups and availability zones for the aforementioned subnet groups
      subnet_type: It's a map of subnet groups and subnet type (Used to associate route table to the SGs) for the aforementioned subnet groups
      ```
   c. s3 variables
      ```
      The plan is to use S3 to serve UI related data or static files and using cloudfront. Although S3 can be spun up individually also.
      variables:
      bucket_name: For storing ui files, s3 bucket needs to be created and it should be unique globally.
      s3_bucket_enabled: Boolean (true/false) value to create/skip the s3 bucket.
      s3_versioning_enabled: Use 'Enabled' for maintaining the versions of bucket and its contents/ 'Disabled' to skip versioning.
      force_destroy: Set the value to true to force the destruction of a resource, even if it has dependencies or is in an error state. Set false to skip.
      ```
   d. cloudfront: Plan is to use Cloudfront in conjunction with the aforementioned s3 bucket. It will also provide a DNS to access the UI.
      ```
      frontend_cloudfront_enabled: Boolean (true/false) value to create/skip the cloudfront distribution.
      default_root_object: set this value for path to root object of UI (eg. index.html).
      ```

   <br>
   e. ASG (both frontend and backend) leverages a load balancer(internal for backend and external for  frontend)  
      
      Scaling can be schedule based to increase/decrease ec2 instances at specific time/s.
      
      Scaling can also be done on the basis of cpu utilization and for this cloudwatch alarm is being used.

      ```NOTE: desired_capacity, max_size, min_size needs to be defined for asg to work```       
      
   <br>

   f. Frontend ASG:
      Frontend ASG is used to serve frontend web application (if not using S3+Cloudfront). Also it can be used as bastion host for the backend ec2 instances.
      ```
      frontend_ec2_enabled: Boolean (true/false) value to create/skip the ec2 instance.
      frontend_asg_instance_type: set instance type depending on specific requirements(e.g. CPU, Memory).
      public_ip_enabled: Boolean (true/false) value to assign/skip public IP address for the ec2 instance.
      frontend_asg_desired_capacity: desired number of instances that should be running in the group.
      frontend_asg_max_size: upper limit on the number of instances that can be launched by ASG.
      frontend_asg_min_size: lower limit on the number of instances that can be launched by ASG.
      frontend_asg_scheduling_enabled: (true/false) value to define/skip specific time-based scaling events for ASG.
      public_key_path: set path to generated public key.
      start_time_upscale, end_time_upscale : schedule time for upscaling.
      start_time_downscale, end_time_downscale : schedule time for downscaling.

      
      frontend_asg_scaling_adjustment_upscale: number of instances to scale up by when a scaling event(cpu utilization exceeding threshold)is triggered.
      frontend_asg_cooldown_upscale: time period after a scaling activity before any further scaling activity can occur (in seconds).
      frontend_cloudwatch_up_period: time period for which the metric needs to exceed the threshold before the alarm triggers a scaling action (in seconds).
      frontend_cloudwatch_up_threshold: threshold (CPU Utilization in %) beyond which scaling event needs to be triggered.

      frontend_asg_scaling_adjustment_downscale: number of instances to scale down by when a downscaling event(cpu utilization fall below threshold)is triggered.
      frontend_asg_cooldown_downscale: time period after a downscaling activity before any further downscaling activity can occur (in seconds).
      frontend_cloudwatch_down_period: time period for which the metric needs to be less than the threshold before the alarm triggers a downscaling action (in seconds).
      frontend_cloudwatch_down_threshold: threshold (CPU Utilization in %) below which downscaling event needs to be triggered.

      frontend_asg_dynamic_scaling_enabled: (true/false) set value to enable/disable dynamic scaling.
      ``` 

   g. Backend ASG: Refer to Frontend ASG

   h. EKS: EKS should be used to create managed kubernetes cluster and node groups for the backend service. Also, there is an Application loadbalancer as entrypoint for the cluster
      and for restricting the access the iam role for cluster and nodes are defined. The nodes are placed in the private subnet inside the vpc created.
         
      Change the following parameters if you want to create more/fewer nodes:
      ``` 
      eks_desired_num_of_nodes
      eks_max_num_of_nodes
      eks_min_num_of_nodes
      ```
   ```Note: For EKS node groups to be created, a minimum of 2gb memory will be required to join the cluster. Otherwise the node will not able to join the EKS cluster.```
<br><br>
   i. ECS: ECS should be used to create up a managed container service by spinning up an ec2 machine or by using fargate engine.
      So ECS works in a way that there is a task definition file (eg. service.json) and tasks are defined inside it and that tasks are spinning up the containers inside the infrastructure created.
      These are the following parameters below needs to define:
      ```
      ecs_launch_type: The possibe values are ec2/fargate
      ecs_cpu_value: Choose the appropriate value for cpu used by containers
      ecs_memory_value: Choose the appropriate value for memory used by containers
      desired_count_for_task_defination: Count for the instances in the task defination file
      ```

   j. RDS:  These are the following parameters to set rds variables:
      ```
      rds_instance_class: set the instance type that meets the required database workload
      allocated_db_storage: required storage size to be allocated for database
      db_engine_name: name of the database engine to be used for rds instance
      db_engine_version: version of database engine 
      db_port: default port of used database engine
      skip_db_final_snapshot: set to false for taking snapshot while deleting rds instance.
      ```

   k. IAM: IAM should be used to assign roles for access to various AWS resources.
      ```
      s3_bucket_name: name of the s3 bucket which ec2 instance needs to access

   ```Note: After changing above variable cd to modules/asg and change the frontend_userdata.sh as per requirements (eg. install java for java application & install npm for js applicaton) after that change the download/cp file location to the s3 bucket where the project is exactly placed```
       

5. After setting all the values, do these following steps
   ```bash
   terraform init
   terraform plan
   terraform apply
    ```
   ```NOTE: use -var-file <custom tfvar file path> flag if using a tfvar file other than terraform.tfvar in plan and apply commands```


6. Now, cd to eks_controller, execute the following steps
   ```bash
   terraform init
   terraform plan
   terraform apply
    ```

Some examples for the infrastructure created in this project are mentioned below:
1. First one is networking part which will remain same for all types of infrastructure i.e: ```vpc, subnets, route tables, internet gateway, nat gateway, elastic ip. ```
2. Next One is we have frontend/backend infrastructure with following parameters:
   ```
   s3 with cloudfront to host frontend web application 
   or frontend asg with loadbalancer attached for the frontend application with security group attached
   and backend asg with internal loadbalancer attached for backend application with security group attached
   Autoscaling groups are having dynamic upscale/downscale based on schedule and cpu usage for the application instances.
   For Database Connectivity rds has been setup and provide details for database which can be used in the applications.
   ```
3. The Last type of infrastructure is for backend eks infrastructure:
   ```
   EKS cluster can have backend infrastructure created with iam roles for cluster/node and nodes are attached with the cluster.
   We can also attach internal loadbalancer through aws-ingress-nginx-controller (for nlb)/ aws-alb-controller (for alb) which can be installed using kubernetes utility.
   The loadbalancer dns will only be accessible from bastion host inside vpc.
   ```

#

# Steps to follow in order to provision infra on AWS using GitHub workflows

## PRE-REQUISITES:
#
### A. Setting Secrets in the GitHub Repository (Common for any type of architecture)

- GitHub Secrets are a way to securely store and manage sensitive information, such as API keys, access tokens, or passwords, in your GitHub repositories. Workflows in this project is using secrets to store credentials.

- In order to set secrets, inside the github repository, move to "Settings". In the left sidebar, click on "Secrets and variables" and go to "Actions". Now, use "New repository secret" button to set secrets.

- Create 2 github secrets with the names `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` to store access key and secret key respectively of your aws account.


- `Note` : To get "Access key" and "Secret Access key" of your AWS account do the following :

        1. Log in into your AWS account.
        2. Click on your profile name and go to security credentials.
        3. In the 'Access Key Section' select 'create access key' and after creation copy them somewhere or download the .csv file

#

### B. IMPORTANT : Things to know about GitHub Actions before proceeding forward (Common for any type of architecture) :

- GitHub Actions brief description:

        1. GitHub Actions is a continuous integration and continuous delivery (CI/CD) platform that allows us to automate our build, test, and deployment pipeline. 
        2. We can create workflows that build and test every pull request to our repository, or push to our repository, or deploy merged pull requests to production and many more.
        3.  A workflow is a configurable automated process that will run one or more jobs. Workflows are defined by a YAML file checked in to our repository and will run when triggered by an event in your repository, or they can be triggered manually, or at a defined schedule.
    
    To know more about github actions refer [GitHub Actions](https://docs.github.com/en/actions/learn-github-actions/understanding-github-actions)

##

- Creating github actions workflow file :

        1. Create a folder with `.github` name in the repository, inside that create another folder with name `workflows`.
        2. All workflow files must be stored inside `.github/workflows/` folder.
        3. Create a workflow file with any preferred name and with `.yml` extension.

##

- Understanding the workflow file(refer to `.github/workflows/create-state-s3.yaml` workflow for better understanding) :

    1. `name` section in the file represents the name of the workflow

    2. `on` section is used to specify the `event(s)` on which the workflow should be triggered for this workflow. 
    Here `workflow_dispatch` event is used that means we have to manually start the workflow. If the event is `push` that means whenever we push to the repository the workflow will run (we can customize for options like push to specific repository, not to specific repository... etc). To understand more about `events` refer [Events in GitHub Actions](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows)

    3. `jobs` sections is where we create all jobs. A workflow job is a set of steps that execute on the same runner. Here `deploy` is the name of the job. We use `runs-on` to mention which runner should be used to run all the steps in the job. A runner is a machine on which the job runs. In this case we are using virtual machine hosted by GitHub and it is using `ubuntu` latest OS. In the `steps` section we define all the steps in the job. A step can be a command or  an action which is a pre-defined job. 

        Steps in the job :

            a. First step uses a `v2` of `action/checkout` action which is used to checkout the code in repo into the runner.
            b. In the second step we are using `v1` of `aws-actions/configure-aws-credentials` which is used to log into the aws account. It uses the secrets we created earlier.
            c. Installing terraform using the action `hashicorp/setup-terraform`
            d. We are running terraform init, plan and apply commands for the terraform code in the folder `./BASIC-INFRA-SMALL-SCALE/state-s3` for creating s3 bucket and Dynamo DB. 
            e. Last step for committing the statefile created by terraform to the desired repository by providing all required options. A statefile is a file that keeps track of resources created by our configuration and maps them to real-world resources. Set commit_user_name & commit_user_email for committing and maintaining the statefile for s3 bucket and dynamodb table. Also create user's name, email and PAT for the project so that one user's credentials don't reflect in the commits from workflow triggered by any member of the team.

        For more about terraform refer this [link](https://developer.hashicorp.com/terraform/docs).


- To run the workflow go to `Actions` tab in the repo and select the workflow name and click on `Run Workflow` option on the right.

#

### C. Creating workflows to generate artifact files

- To write commands to generate artifact in a shell script, create a shell script in the code repository and write all the required commands to install all libraries and dependencies required for the application to run and to create the artifact file(We can achieve this directly by workflows also).
- Now in the code repository create a github workflow file which will be used to generate the artifact file. Refer to the workflow file in `monolith/hello/.github/workflows/package-war.yaml` and create the workflow file specific to your application. 

- Description about the workflow `package-war.yaml`:
    
        1. Triggers on push to main branch event and can be started manually also.
        2. Job name is `build` as we are building the artifact here. Using `Ubuntu` runner. First step is checking out the code in repo using the action `action/checkout`. Next step installing `java` in the runner with required configuration. In the next step giving execute permission to the shell script created earlier and executing it. Logging into AWS in the next step. In the final step we are storing the artifact. Artifacts can be stored anywhere, but it should be downloadable. 

- Run the workflow 
- Generate all the required artifacts in the similar way for all code repositories.
#
### D. Creating S3 Bucket and Dynamo DB 
##
- Follow these steps to create s3 bucket and dynamodb for storing the terraform statefile.
##
- Create a new repository in the project and copy the `BASIC-INFRA-SMALL` folder from the branch specific to your architecture(e.g. copy from monolith branch in case you are deploying a monolith application) into the created repository. It contain necessary terraform code which we will be using in the workflows. 
##
- In this file `BASIC-INFRA-SMALL-SCALE/state-s3/variables.tf` modify the default s3 bucket name (state_bucket_name) and dynamodb table name (state_lock_table_name). 

- `NOTE` : The name for the s3 bucket must be unique globally.
##
- In the master branch of newly created repository, create a workflow file with any preferred name and with `.yml` extension and copy the `.github/workflows/create-state-s3.yaml` file content into that workflow file.

##

- To understand and customize the `.github/workflows/create-state-s3.yaml` workflow file read the following points:

    1. `name` section in the file represents the name of the workflow
    2. Here `workflow_dispatch` event is used that means we have to manually start the workflow. 
    3. Here `deploy` is the name of the job. In this case we are using virtual machine hosted by GitHub and it is using `ubuntu` latest OS.

        Steps in the job :
         
            a. First step uses a `v2` of `action/checkout` action which is used to checkout the code in repo into the runner.
            b. In the second step we are using `v1` of `aws-actions/configure-aws-credentials` which is used to log into the aws account. It uses the secrets we created earlier.
            c. Installing terraform using the action `hashicorp/setup-terraform`
            d. We are running terraform init, plan and apply commands for the terraform module `./BASIC-INFRA-SMALL-SCALE/state-s3` for creating s3 bucket and Dynamo DB.             
            e. Last step for committing the statefile created by terraform to the main branch by providing all required options. Set commit_user_name & commit_user_email for committing and maintaining the statefile for s3 bucket and dynamodb table. Also create user's name, email and PAT for the project so that one user's credentials don't reflect in the commits from workflow triggered by any member of the team.


- Run this workflow to create a s3 bucket with Dynamodb table. To run the workflow go to `Actions` tab in the repo and select the workflow name and click on `Run Workflow` option on the right. The s3 bucket being created is where terraform.tfstate file for the application will be stored.
#
#
## 1. GITHUB ACTIONS FOR MONOLITH APPLICATIONS
#

### A. Customizing AWS resources Configuration through terraform
- Go to `BASIC-INFRA-SMALL-SCALE/terraform.tfvars` and customize the configuration according to your needs.
- Refer to the above mentioned description of all variables in the readme file once before modifying the value.
- In the `BASIC-INFRA-SMALL-SCALE/backend.tf` modify the bucket name and dynamo db table name with the ones we created earlier. 

#

### B. Create: Deploy infra and monolith application
- Open `BASIC-INFRA-SMALL-SCALE/modules/asg/frontend_userdata.sh` it is user data which will run during the creation of ec2 instance. Here we are downloading the artifact file(all required artifacts should be downloaded) and installing apache-tomcat to view the monolith application. Customize the code by doing  changes according to your needs.

##
- In the master branch of newly created repository, create a workflow file with any preferred name and with `.yml` extension and copy the `.github/workflows/deploy-monolith-architecture-application.yaml` file content into that workflow file.

##

- To understand and customize the `.github/workflows/deploy-monolith-architecture-application.yaml` workflow file read the following points:
    1. `name` section in the file represents the name of the workflow
    2. Here `workflow_dispatch` event is used that means we have to manually start the workflow. 
    3. Here `deploy` is the name of the job. In this case we are using virtual machine hosted by GitHub and it is using `ubuntu` latest OS.
    
        Steps in the job :

            a. First step uses a `v2` of `action/checkout` action which is used to checkout the code in repo into the runner.
            b. In the second step we are using `v1` of `aws-actions/configure-aws-credentials` which is used to log into the aws account. It uses the secrets we created earlier.
            c. Installing terraform using the action `hashicorp/setup-terraform`
            d. We are running terraform init, plan and apply commands for all the terraform modules in `./BASIC-INFRA-SMALL-SCALE` for infrastructure and deploying the application. 

- Setup the repository secrets (if not done already ) && Run this workflow to deploy infrastructure and application with required configuration. To run the workflow go to `Actions` tab in the repo and select the workflow name and click on `Run Workflow` option on the right.

- Congrats! Your application is deployed. Access the application using loadbalancer DNS.

#

### C. Destroy: infra and monolith application
##
- Follow these steps to destroy infrastructure for monolith application created earlier.
##
- In the master branch of newly created repository, create a workflow file with any preferred name and with `.yml` extension and copy the `.github/workflows/destroy-monolith-architecture-application.yaml` file content into that workflow file.

##

- To understand and customize the `.github/workflows/destroy-monolith-architecture-application.yaml` workflow file read the following points:
    1. `name` section in the file represents the name of the workflow
    2. Here `workflow_dispatch` event is used that means we have to manually start the workflow. 
    3. Here `destroy` is the name of the job. In this case we are using virtual machine hosted by GitHub and it is using `ubuntu` latest OS. 

        Steps in the job :
    
            a. First step uses a `v2` of `action/checkout` action which is used to checkout the code in repo into the runner.
            b. In the second step we are using `v1` of `aws-actions/configure-aws-credentials` which is used to log into the aws account. It uses the secrets we created earlier.
            c. Installing terraform using the action `hashicorp/setup-terraform`
            d. We are running terraform init and destroy commands for all the terraform modules in `./BASIC-INFRA-SMALL-SCALE` for destroying infrastructure and the application created using terraform.

- Run this workflow to destroy the infrastructure and application. To run the workflow go to `Actions` tab in the repo and select the workflow name and click on `Run Workflow` option on the right.


#

## 2. GITHUB ACTIONS FOR MULTI-TIER APPLICATION
#

### A. Customizing AWS resources Configuration through terraform
- Go to `BASIC-INFRA-SMALL-SCALE/terraform.tfvars` and customize the configuration according to your needs.
- Refer to the above mentioned description of all variables in the readme file once before modifying the value.
- In the `BASIC-INFRA-SMALL-SCALE/backend.tf` modify the bucket name and dynamo db table name with the ones we created earlier. 

#

### B. Create: Deploy infra and multi-tier application
- In `BASIC-INFRA-SMALL-SCALE/modules/asg/` the files `frontend_userdata.sh` and `backend_userdata.sh` are user data which will run during the creation of ec2 instance. Here we are downloading the artifact files and installing apache-tomcat to view the application. Customize the code by doing necessary changes accordingly as per your needs.

##
- In the master branch of newly created repository, create a workflow file with any preferred name and with `.yml` extension and copy the `.github/workflows/deploy-architecture-application-multi-tier.yaml` file content into that workflow file.

##

- To understand and customize the `.github/workflows/deploy-architecture-application-multi-tier.yaml` workflow file read the following points:
    1. `name` section in the file represents the name of the workflow
    2. Here `workflow_dispatch` event is used that means we have to manually start the workflow. 
    3. Here `deploy` is the name of the job. In this case we are using virtual machine hosted by GitHub and it is using `ubuntu` latest OS. The `steps` are :

        Steps in the job :

            a. First step uses a `v2` of `action/checkout` action which is used to checkout the code in repo into the runner.
            b. In the second step we are using `v1` of `aws-actions/configure-aws-credentials` which is used to log into the aws account. It uses the secrets we created earlier.
            c. Installing terraform using the action `hashicorp/setup-terraform`
            d. Create secrets for username(TF_VAR_db_username) and password(TF_VAR_db_password) for database and using them as env variables. We are running terraform init, plan and apply commands for all the terraform modules in `./BASIC-INFRA-SMALL-SCALE` for infrastructure and deploying the application.

- Run this workflow to deploy infrastructure and application with required configuration. To run the workflow go to `Actions` tab in the repo and select the workflow name and click on `Run Workflow` option on the right.

- Congrats! Your application is deployed. Access the application using loadbalancer DNS.

#

### C. Destroy: infra and multi-tier application

- Follow these steps to destroy infrastructure for multi-tier application created earlier.
##
- In the master branch of newly created repository, Create a workflow file with any preferred name and with `.yml` extension and copy the `.github/workflows/destroy-architecture-application-multi-tier.yaml` file content into that workflow file.

##

- To understand and customize the `.github/workflows/destroy-architecture-application-multi-tier.yaml` workflow file read the following points:
    1. `name` section in the file represents the name of the workflow
    2. Here `workflow_dispatch` event is used that means we have to manually start the workflow. 
    3. Here `destroy` is the name of the job. In this case we are using virtual machine hosted by GitHub and it is using `ubuntu` latest OS.

        Steps in the job :
    
            a. First step uses a `v2` of `action/checkout` action which is used to checkout the code in repo into the runner.
            b. In the second step we are using `v1` of `aws-actions/configure-aws-credentials` which is used to log into the aws account. It uses the secrets we created earlier.
            c. Installing terraform using the action `hashicorp/setup-terraform`
            d. We are running terraform init and destroy commands for all the terraform modules in `./BASIC-INFRA-SMALL-SCALE` for destroying infrastructure and the application created using terraform.

- Run this workflow to destroy the infrastructure and application. To run the workflow go to `Actions` tab in the repo and select the workflow name and click on `Run Workflow` option on the right.

#


## 3. GITHUB ACTIONS FOR EKS CLUSTER 
#

### A. Customizing AWS resources t through terraform
- Go to `BASIC-INFRA-SMALL-SCALE/terraform.tfvars` and customize the configuration according to your needs.
- Refer to the description of all variable in the readme file once before modifying the value.
- In the `BASIC-INFRA-SMALL-SCALE/backend.tf` modify the bucket name and dynamo db table name with the ones we created earlier. 

#

### B. Create: Deploy EKS

##
- In the master branch of newly created repository, create a workflow file with any preferred name and with `.yml` extension and copy the `.github/workflows/deploy-architecture-application-eks.yaml` file content into that workflow file.

##

- To understand and customize the `.github/workflows/deploy-architecture-application-eks.yaml` workflow file read the following points:
    1. `name` section in the file represents the name of the workflow
    2. Here `workflow_dispatch` event is used that means we have to manually start the workflow. 
    3. Here `deploy` is the name of the job. In this case we are using virtual machine hosted by GitHub and it is using `ubuntu` latest OS. The `steps` are :
    
        Steps in the job :

            a. First step uses a `v2` of `action/checkout` action which is used to checkout the code in repo into the runner.
            b. In the second step we are using `v1` of `aws-actions/configure-aws-credentials` which is used to log into the aws account. It uses the secrets we created earlier.
            c. Installing terraform using the action `hashicorp/setup-terraform`
            d. We are running terraform init, plan and apply commands for all the terraform modules in `./BASIC-INFRA-SMALL-SCALE` for creating EKS Cluster. Amazon Elastic Kubernetes Service (Amazon EKS) is a managed service that you can use to run Kubernetes on AWS without needing to install, operate, and maintain your own Kubernetes control plane or nodes. 
            e. We are running terraform init, plan and apply commands for all the terraform code in `./BASIC-INFRA-SMALL-SCALE/eks-controller` for installing eks-controller. The EKS controller simplifies management of EKS clusters in AWS, integrates with load balancers for efficient traffic distribution, and ensures seamless integration with other AWS services.
            f. Installing `kubectl` which is command line tool for kubernetes.
            g. Installing AWS CLI(Command line interface)
            h. Updating the kubeconfig file for an Amazon EKS cluster named `new_eks_cluster` in a workflow file. The kubeconfig file is a configuration file used by kubectl to authenticate and interact with a Kubernetes cluster. It contains information about the cluster's API server, authentication details, and other cluster-specific settings. 
            i. Installing the application using kubectl apply. Provide the location of your kubernetes manifest file there. 

- Run this workflow to create eks cluster with required configuration. To run the workflow go to `Actions` tab in the repo and select the workflow name and click on `Run Workflow` option on the right.

- Congrats! Your EKS cluster is deployed. 

#

### C. Destroy: Deployed EKS

##
- Follow this section to destroy the EKS Cluster you created.
##
- In the master branch of newly created repository, create a workflow file with any preferred name and with `.yml` extension and copy the `.github/workflows/deploy-architecture-application-eks.yaml` file content into that workflow file.

##

- To understand and customize the `.github/workflows/deploy-architecture-application-eks.yaml` workflow file read the following points:
    1. `name` section in the file represents the name of the workflow
    2. Here `workflow_dispatch` event is used that means we have to manually start the workflow. 
    3. Here `destroy` is the name of the job. In this case we are using virtual machine hosted by GitHub and it is using `ubuntu` latest OS. The `steps` are :
    
        Steps in the job :
    
            a. First step uses a `v2` of `action/checkout` action which is used to checkout the code in repo into the runner.
            b. In the second step we are using `v1` of `aws-actions/configure-aws-credentials` which is used to log into the aws account. It uses the secrets we created earlier.
            c. Installing terraform using the action `hashicorp/setup-terraform`
            d. Installing `kubectl` which is command line tool for kubernetes.
            e. Installing AWS CLI(Command line interface)
            f. Deleting the application using `kubectl delete`. Provide the location of your kubernetes manifest file there. 
            g. Updating the kubeconfig file for an Amazon EKS cluster named `new_eks_cluster` in a workflow file. The kubeconfig file is a configuration file used by kubectl to authenticate and interact with a Kubernetes cluster. It contains information about the cluster's API server, authentication details, and other cluster-specific settings. 
            h. We are running terraform init and destroy commands for all the terraform code in `./BASIC-INFRA-SMALL-SCALE/eks-controller` for deleting eks-controller.
            i. We are running terraform init and destroy commands for all the terraform modules in `./BASIC-INFRA-SMALL-SCALE` for deleting the eks cluster. e
        

- Run this workflow to destroy eks cluster. To run the workflow go to `Actions` tab in the repo and select the workflow name and click on `Run Workflow` option on the right.

# 
#

### Destroying S3 bucket and Dynamo DB (Common for all three architectures)
- `NOTE` : It is recommended not to delete s3 bucket and dynamodb table until you are not going to use this infrastructure again in future [If you delete accidentally go to the workflow that you have to use and change (in the working directory BASIC-INFRA-SMALL) the terraform init to terraform init -migrate]. 
##
- In the master branch of newly created repository, create a workflow file with any preferred name and with `.yml` extension and copy the `.github/workflows/destroy-state-s3.yaml` file content into that workflow file.

##

- To understand and customize the `.github/workflows/destroy-state-s3.yaml` workflow file read the following points:
    1. `name` section in the file represents the name of the workflow
    2. Here `workflow_dispatch` event is used that means we have to manually start the workflow. 
    3. Here `destroy` is the name of the job. In this case we are using virtual machine hosted by GitHub and it is using `ubuntu` latest OS. The `steps` are :

        Steps in the job :

            a. First step uses a `v2` of `action/checkout` action which is used to checkout the code in repo into the runner.
            b. In the second step we are using `v1` of `aws-actions/configure-aws-credentials` which is used to log into the aws account. It uses the secrets we created earlier.
            c. Installing AWS CLI(Command line interface)
            d. Installing terraform using the action `hashicorp/setup-terraform`
            e. We are running terraform init and destroy commands for the terraform module `./BASIC-INFRA-SMALL-SCALE/state-s3` for destroying s3 bucket and Dynamo DB. 
            f. Last step for committing the statefile created by terraform to the desired repository by o all required options. Set commit_user_name & commit_user_email for committing and maintaining the statefile for s3 bucket and dynamodb table. Also create user's name, email and PAT for the project so that one user's credentials don't reflect in the commits from workflow triggered by any member of the team.


- Run this workflow to destroy the s3 bucket with Dynamodb table which are created earlier. To run the workflow go to `Actions` tab in the repo and select the workflow name and click on `Run Workflow` option on the right. 
