# myalfred-iac
myAlfred IaC Repo

# Steps to provision Infra.

Create the S3 backend bucket and DynamoDB table manually and update in the Terraform(backend.tf).


- Run the following command to provision the IaC.
- Update the terraform.tfvars file accordingly.
- Assign the following IAM Roles to that account and update the IAM Role ARNs in the "aws-auth-cm.yaml" file.
e.g:
    - arn:aws:iam::116981791371:role/eks-myalfred-dev-eks-node-group-20241204055607436800000002 (Handle this carefully)
    - arn:aws:iam::116981791371:role/AWSReservedSSO_AWSAdministratorAccess_f966aafc09b1d2a4
    - arn:aws:iam::116981791371:role/EKS-Github-Actions
    - arn:aws:iam::116981791371:role/AWSReservedSSO_AWSDeveloperAccess_5f44808e5232ea5e
- Use the Terraform CLI Role to run the Terraform commands to provision the Infra, instead Secret and Access keys.

# To Provision the Dev
cd myalfred-iac/environments/dev/
terraform init
terraform plan -var-file="credentials.tfvars"
terraform apply -var-file="credentials.tfvars"

# To Provision the Prod
cd myalfred-iac/environments/prod/
terraform init
terraform plan -var-file="credentials.tfvars"
terraform apply -var-file="credentials.tfvars"