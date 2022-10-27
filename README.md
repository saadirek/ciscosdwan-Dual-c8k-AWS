***PreRequisite*** 

Install Terraform
- https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli

Install AWS_CLI 
- https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

Configure KEY and Access Token for AWS in the environment.
- https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-build

Login to the vManage 
- Copy the Device Template from the default AWS template named a new one 
- Attach 2 x C8000V to the newly created template.
- Generate the Bootstrap and download 
- Copy to the terraform folder and rename them “config_1.cfg” and “config_2.cfg”


***What this script will do***
- Create Transit VPC
- Create 4 x Subnet : 2 x WAN, 2 x LAN in a different AZ 
- Create the 4 x ENI. 2 x WAN, 2 x LAN assigned to 4 different subnets
- Create 2 x Elastic IP and associated to the 2 x WAN 
- Create the Security Group for WAN to all SSH inbound
- Create IGW and associate the IGW to the VPC default route table
- Create the 2 x C8KV instance : 17.06.1a with 2 interface.
- User Data = “config_1.cfg” for the C8KV-1
- User Data = “config_2.cfg” for the C8KV-2


***How to run the script***

Make sure all requried files are located in the same folder
```        
-rw-r--r--@ 1 sadirek  staff   5877 Oct 27 07:47 config_1.cfg
-rw-r--r--@ 1 sadirek  staff   5877 Oct 27 07:47 config_2.cfg
-rw-r--r--  1 sadirek  staff   3758 Oct 27 09:22 main.tf
-rw-r--r--  1 sadirek  staff    179 Oct 27 09:29 terraform.tfstate
-rw-r--r--  1 sadirek  staff  35054 Oct 27 09:24 terraform.tfstate.backup
-rw-r--r--  1 sadirek  staff    193 Oct 27 09:06 terraform.tfvars
-rw-r--r--  1 sadirek  staff    399 Oct 27 09:06 variables.tf
```


Edit Variables in the ”terraform.tfvars”

```
vi terraform.tfvars 
```
```
deployment_region = "ap-southeast-1"
wan_subnet_1 =  "10.40.0.0/28"
lan_subnet_1 =  "10.40.0.128/28"
wan_subnet_2 =  "10.40.0.32/28"
lan_subnet_2 =  "10.40.0.160/28"
vpc_cidr = "10.40.0.0/24"
```




Make sure 2 x devices s/n are attached to the template 
Generate Bootstraps configuration and download it.
Copy and rename to config_1.cfg and config_2.cfg
```
sadirek@SADIREK-M-F4YJ onboard-c8kv % more config_1.cfg 
Content-Type: multipart/mixed; boundary="===============4667944370214818775=="
MIME-Version: 1.0

--===============4667944370214818775==
Content-Type: text/cloud-config; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="tmpypxcbs52"

#cloud-config
vinitparam:
 - org : mt-vmanage-demo - 627179
 - otp : 53158421d4d74e7c96343256805ec25f
 - vbond : vbond-150730692.sdwan.cisco.com
 - uuid : C8K-D5A65D5E-E0D4-9407-E6BA-047A19374D7F

--===============4667944370214818775==
Content-Type: text/cloud-boothook; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="config-C8K-D5A65D5E-E0D4-9407-E6BA-047A19374D7F.txt"

#cloud-boothook
  system
   ztp-status            success
   pseudo-confirm-commit 300
   personality           vedge
   device-model          vedge-C8000V
   chassis-number        C8K-D5A65D5E-E0D4-9407-E6BA-047A19374D7F

```

Run the terraform script
```
terraform apply -var-file "terraform.tfvars"
```






