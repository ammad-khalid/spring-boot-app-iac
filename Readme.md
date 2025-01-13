This folder contains Terraform script and application to deploy from GitHub actions.

Step 1: Create an oidc connector.

To create an oidc connector, create identity provider with following details:
- webIdentity
- provider URL: Use https://token.actions.githubusercontent.com
- "Audience": Use sts.amazonaws.com

Then create webidentity assume role for AWS account authentication, this role should have following trust relationship policy:
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::779160054397:oidc-provider/token.actions.githubusercontent.com"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
                    "token.actions.githubusercontent.com:sub": "repo:owner-name/spring-boot-app:ref:refs/heads/master"
                }
            }
        }
    ]
} 

attach permissions like:
AmazonEKSWorkerNodePolicy
AmazonEKSClusterPolicy
AmazonEC2FullAccess
AmazonEC2ContainerRegistryReadOnly
AdministratorAccess

Step 2:

Terraform folder contains the script for deploying infrastructure that includes VPC (public, private subnets), EKS cluster on private subnet, ALB controller and bastion host to access the EKS cluster. It has GitHub workflow file to deploy select the operations that needs to be performed on Terraform script like plan, apply or destroy.

Important note:

- Make sure to add the ARN for this role in eks.tf (aws_auth) resource like this:
      {
        rolearn  = "arn:aws:iam::${var.account_id}:role/assume-role-github-integration"
        username = "assume-role-github-integration"
        groups   = ["system:masters"]
      },     

- Make dynamodb table and your state file.

- Create a key pair in AWS to pass the value in terraform.tvars file (key_name) 

Step 3:

App folder contains the application deployment with Kubernetes standard and Helm deployment both but deployment is configured to run using custom helm charts. Just run make change in any file and it will run the CICD flow to build the code, image, push image, and deploy the app.

Note: update the variables in git secrets
AWS_ACCOUNT_ID = AWS Account ID
DEV_AWS_ROLE_ARN = Assume role for AWS authentication.

- To access the application use the alb url along with route like this:

http://k8s-java-appingre-826b77adb5-1213071422.us-east-1.elb.amazonaws.com/lazy

Links:

ocid: https://docs.github.com/en/actions/security-for-github-actions/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services
https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-idp_oidc.html#idp_oidc_Create_GitHub
