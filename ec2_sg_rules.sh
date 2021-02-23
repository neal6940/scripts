#!/bin/bash

# use the faws toolbox to grab the aws accounts for the customer
aws_accounts=$(faws account list-accounts -r 1122393 |grep 'AWS Account'|awk '{print $3}')


# print the csv headers to the output file
echo "\"Account\"\,\"Region\"\,\"Group-Name\"\,\"Group-ID\"\,\"In\/Out\"\,\"Protocol\"\,\"Port\"\,\"Source/Destination\"" > ec2_sg_rules.csv

# parse through each aws account and output the python results to a csv
for aws_account in ${aws_accounts[@]}
do
    echo $aws_account
    # log into the specific account
    DDI=1122393; ACCT=$aws_account; faws -r $DDI env -a $ACCT && eval "$(faws -r $DDI env -a $ACCT)"
    python3 ./ec2_sg_rules.py $aws_account >> ec2_sg_rules.csv
done
