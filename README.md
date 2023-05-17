# Terraform AWS Starter

### Guidelines to add modules:
1. Create separate file for resource creation module, variable, provider and output file.
2. Never pass secrets in code like aws access key, secret key or anyother password etc.
3. Never checked in private key in repo
4. Code should be moduler enough. So that we can easily change one module without affecting other module.


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
   e. ASG (both frontend and backend) leverages a load balancer(internal for backend and internet-facing for frontend)  
      
      Scaling can be schedule based to increase/decrease ec2 instances at specific time/s.
      
      Scaling can also be done on the basis of cpu utilization and for this cloudwatch alarm is being used.

      ```NOTE: desired_capacity, max_size, min_size needs to be defined for asg to work```       
      
   <br>

   f. Frontend ASG:
      Frontend ASG is used to serve frontend web application (if not using S3+Cloudfront or s3 static website hosting). Also it can be used as bastion host for the backend ec2 instances.
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

   g. Backend ASG: Similar to frontend ASG except it uses an internal Load balancer and in order to provide internet access to the instances nat_gateway needs to be enabled. For variable references please refer to Frontend ASG

   h. EKS: EKS should be used to create managed kubernetes cluster and node groups for the backend service. Also, there is an Application loadbalancer as entrypoint for the cluster
      and for restricting the access the iam role for cluster and nodes are defined. The nodes are placed in the private subnet inside the vpc created.
         
      Change the following parameters if you want to create more/fewer nodes:
      ``` 
      eks_desired_num_of_nodes
      eks_max_num_of_nodes
      eks_min_num_of_nodes
      ```
      In order for the load balancers (which also act as ingress controllers) to be able to work we need to create eks_controller. eks_controller is set up as a separate small project with it's state maintained in same bucket and dynamodb table. In order to spin up eks_controller, cd to eks_controller, execute the following steps:
   ```bash
   terraform init
   terraform plan
   terraform apply
    ```      

   ```Note: For EKS node groups to be created, a minimum of 2gb memory will be required to join the cluster. Otherwise the node will not able to join the EKS cluster.```
<br><br>
   i. ECS: ECS should be used to create a managed container service by spinning up an ec2 machine or by using fargate engine.
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

#### Setting scerets in the github repository

GitHub Secrets are a way to securely store and manage sensitive information, such as API keys, access tokens, or passwords, in your GitHub repositories. Workflows in this project is using secrets to store credentials.

In order to set scerets, inside the github repository, move to "Settings". In the left sidebar, click on "Secrets and variables" and go to "Actions". Now, use "New repository secret" button to set scerets.

#### Steps to follow in order to provision infra on AWS using workflows

1. Workflow to deploy state s3 and Dynamodb table

 Run this workflow to create a s3 bucket with Dynamodb table. The s3 bucket being created is where terraform.tfstate file for the application will be stored.

 Following secrets are to be set in github repository before running the workflow:
 `AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY`

 Set commit_user_name & commit_user_email for commiting and maintaing the statefile for s3 bucket and dynaodb table. Also create user's name, email and PAT for the project so that one user's credentials don't reflect in the commits from workflow triggered by any member of the team.

2. Workflow to deploy infra and application eks

```Note: If s3 bucket to store terraform.tfstate is not already present; run the workflow to create it.``` 

 Run this workflow to deploy the whole infrastructure along with eks.
 Before running the workflow, make sure to set the following secrets:

 `AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY`
 
 Variable 'eks_enabled' must be set to true for running this workflow in the terraform.tfvars file. Other variables related to eks should also be set. 

3. Workflow to deploy infra and application multi tier 

```Note: If s3 bucket to store terraform.tfstate is not already present; run the workflow to create it.``` 

 Run this workflow to deploy infrastructure when the application is multitier (i.e. it contains frontend, backend & database).

 Make sure that following variables are set to true and related variables are also set in the terraform.tfvars file for this workflow:

 `frontend_ec2_enabled, backend_ec2_enabled, rds_enabled`

 Following secrets also needs to be set before running the workflow:

 `AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, TF_VAR_db_password, TF_VAR_db_username`

4. Workflow to deploy infra and application monolith

```Note: s3 bucket to store terraform.tfstate file should be created beforehand.``` 

 Run this workflow to deploy infrastructure when the application is a monolith (i.e. it contains only frontend). 
 Before running the workflow, make sure to set the secrets:

 `AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY`
 
 For this workflow, variable "frontend_ec2_enabled" should be set to true and related variables should also be set in terraform.tfvars file.

5. Workflow to destroy infra and application eks

   Run this workflow to destroy the created eks based infrastructure.

6. Workflow to destroy infra and application multi tier

   Run this workflow to destroy the created multi tier infrastructure.

7. Workflow to destroy infra and application monolith

   Run this workflow to destroy the created monolith infrastructure.

8. Workflow to destroy state s3 and Dynamodb table

```Note: Run this workflow only after all other infrastructure resources are destroyed.```

   This workflow destroys the created state s3 bucket and Dynamodb table.


 



 








