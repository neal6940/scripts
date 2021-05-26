#!/bin/bash

DDI=977936; 
ACCT=559742308680; 
current_region=eu-central-1

faws -r $DDI env -a $ACCT && eval "$(faws -r $DDI env -a $ACCT)"

#### NOTE: If some alarms shouldn't be deleted are in criteria, this will cause a problem

# A script to mass delete alarms based on criteria
alarm_list=$(aws --region $current_region cloudwatch describe-alarms --output text --query 'MetricAlarms[?(contains(AlarmName, `CUBE`) == `true`)].{Alarm:AlarmName}')
counter=1

for an_alarm in ${alarm_list[@]}
do
    echo $counter: $an_alarm
    aws cloudwatch delete-alarms --region $current_region --alarm-names $an_alarm
    counter=$[$counter+1]
    if [ $counter -eq 900 ]; then
        break
    fi
done