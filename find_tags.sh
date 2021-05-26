#!/bin/bash
###############################################################################
# neal6940 - 2021-02-24
# Script to search multiple AWS accounts for resources with a specific tag
###############################################################################

faws login
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
        ##### FILTER TYPE ######
        # Key=Name,Values=AMRADOBWEB1041W,AMRADOBDB104W = this is like using an OR stmt
#        aws resourcegroupstaggingapi get-resources --region $account_region --output text --tag-filters Key=Name,Values=EURADONEPERSQL1,AMRATMCATIBM1W,EURAPCLSDB2W,SYDAPCMW160001W,EURAPCLSDB1W,AMRMPAPPDRP01W,AMRMPMBAMSQL2W,AMRMPMBAMSQL1W,ASPMPPEJENWEB1W,AMRMPCFGAETAC1W,ADC2HOSTJMP1W,EDC2HOSTJMP1W --query 'ResourceTagMappingList[*].[ResourceARN, Tags[?Key==`Name`].Value[]|[0], Tags[?Key==`CostCenter`].Value[]|[0], Tags[?Key==`Environment`].Value[]|[0], Tags[?Key==`aws:cloudformation:stack-name`].Value[]|[0]]' | tee -a tags_output.txt
        aws resourcegroupstaggingapi get-resources --region $account_region --output text --tag-filters Key=CaseCode,Values=200241-13 --query 'ResourceTagMappingList[*].[ResourceARN, Tags[?Key==`Name`].Value[]|[0], Tags[?Key==`CostCenter`].Value[]|[0], Tags[?Key==`Environment`].Value[]|[0], Tags[?Key==`aws:cloudformation:stack-name`].Value[]|[0]]' | tee -a tags_output.txt
        echo $aws_account, $account_region | tee -a tags_output.txt
    done
done
