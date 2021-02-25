#!/bin/bash
###############################################################################
# Script to search multiple AWS accounts for resources with a specific tag
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
    account_regions=$(aws ec2 describe-regions --region us-east-1 --query "Regions[].{Name:RegionName}" --output text)
    for account_region in ${account_regions[@]}
    do
        echo $aws_account, $account_region | tee -a tags_output.txt
        #find tags matching FILTER
        aws resourcegroupstaggingapi get-resources --region $account_region --output text --tag-filters Key=CostCenter,Values=15196-11 --query 'ResourceTagMappingList[*].[ResourceARN, Tags[?Key==`Name`].Value[]|[0], Tags[?Key==`CostCenter`].Value[]|[0], Tags[?Key==`Environment`].Value[]|[0], Tags[?Key==`aws:cloudformation:stack-name`].Value[]|[0]]' | tee -a tags_output.txt
    done
done
