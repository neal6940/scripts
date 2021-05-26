#!/bin/bash
###############################################################################
# neal6940 - 2021-04-27
# Script to search multiple AWS accounts and list all VPC CIDR ranges
###############################################################################

DDI=977936; 
echo $DDI | tee tags_output.txt
# use the faws toolbox to grab the aws accounts for the customer
aws_accounts=$(faws account list-accounts -r $DDI |grep 'AWS Account'|awk '{print $3}')

# parse through each aws account
for aws_account in ${aws_accounts[@]}
do
    # parse through each region in each aws account
    ACCT=$aws_account; faws -r $DDI env -a $ACCT > /dev/null && eval "$(faws -r $DDI env -a $ACCT)" 
    ##### USE ALL REGIONS AVAILABLE TO ACCT #####
    account_regions=$(aws ec2 describe-regions --region us-east-1 --query "Regions[].{Name:RegionName}" --output text)
    ##### SPECIFY REGIONS #####
#    account_regions=(us-east-1 us-east-2 us-west-1 us-west-2)
    for account_region in ${account_regions[@]}
    do
        echo $aws_account, $account_region | tee -a tags_output.txt
        aws ec2 describe-vpcs --region $account_region --output text --query 'Vpcs[*].[VpcId, CidrBlock, Tags[?Key==`Name`].Value[]|[0], Tags[?Key==`CostCenter`].Value[]|[0], Tags[?Key==`Environment`].Value[]|[0], Tags[?Key==`aws:cloudformation:stack-name`].Value[]|[0], OwnerId, IsDefault, CidrBlockAssociationSet[0].CidrBlock, CidrBlockAssociationSet[1].CidrBlock]' | tee -a vpcs_output.txt
    done
done
