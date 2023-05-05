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
      ```
   d. cloudfront: Plan is to use Cloudfront in conjunction with the aforementioned s3 bucket. It will also provide a DNS to access the UI.
      ```
      frontend_cloudfront_enabled: Boolean (true/false) value to create/skip the cloudfront distribution.
      default_root_object: set this value for path to root object of UI (eg. index.html).
      ```
   e. Frontend ASG:
      Frontend ASG is used to serve frontend web application (if not using S3+Cloudfront). Also it can be used as bastion host for the backend ec2 instances.
   
   <br>
   f. ASG (both frontend and backend) leverages a load balancer(internal for backend and external for frontend)  
      
      Scaling can be schedule based to increase/decrease ec2 instances at specific time/s.
      
      Scaling can also be done on the basis of cpu utilization and for this cloudwatch alarm is being used.

      ```NOTE: desired_capacity, max_size, min_size needs to be defined for asg to work```       
      
   <br>
   g. EKS: EKS should be used to create managed kubernetes cluster and node groups for the backend service. Also, there is an Application loadbalancer as entrypoint for the cluster
      and for restricting the access the iam role for cluster and nodes are defined. The nodes are placed in the private subnet inside the vpc created.
         
      Change the following parameters if you want to create more/fewer nodes:
      ``` 
      eks_desired_num_of_nodes
      eks_max_num_of_nodes
      eks_min_num_of_nodes
      ```
   ```Note: For EKS node groups to be created, a minimum of 2gb memory will be required to join the cluster. Otherwise the node will not able to join the EKS cluster.```
<br><br>
   h. ECS: ECS should be used to create up a managed container service by spinning up an ec2 machine or by using fargate engine.
      So ECS works in a way that there is a task definition file (eg. service.json) and tasks are defined inside it and that tasks are spinning up the containers inside the infrastructure created.
      These are the following parameters below needs to define:
      ```
      ecs_launch_type: The possibe values are ec2/fargate
      ecs_cpu_value: Choose the appropriate value for cpu used by containers
      ecs_memory_value: Choose the appropriate value for memory used by containers
      desired_count_for_task_defination: Count for the instances in the task defination file
      ```

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