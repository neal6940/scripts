# AWS CloudWatch Metric Alarms Updates - Name & Threshold
# 2020-11-30 
# cw_alarm_rename.py
#
# update alarm names from 3 cli args:
# - old alarm name
# - new alarm name 
# - new alarm threshold
#
# MUST SET:
# AWS_ACCESS_KEY_ID=
# AWS_SECRET_ACCESS_KEY=
# AWS_SESSION_TOKEN=
# AWS_DEFAULT_REGION=
#
# USE:
#  $ python3 cw_alarm_rename.py "Current Alarm Name" "New Alarm Name" Optional-New-Threshold-Number
# 
#

import sys
import boto3


def rename_alarm(alarm_name, new_alarm_name, new_alarm_threshold):
    client = boto3.client('cloudwatch')
    alarm = client.describe_alarms(AlarmNames=[alarm_name])

    if not alarm['MetricAlarms']:
        raise Exception("Alarm '%s' not found" % alarm_name)

    # ALARM NAME; NEW ALARM NAME; NEW THRESHOLD
    print(f'{alarm_name}; {new_alarm_name}; {new_alarm_threshold} ')
    alarm = alarm['MetricAlarms'][0]

    # If no new threshold arg, set to current threshold
    if new_alarm_threshold == None:
        new_alarm_threshold = alarm['Threshold']

    # put the new metric alarm
    client.put_metric_alarm(
        AlarmName=new_alarm_name,
        ActionsEnabled=alarm['ActionsEnabled'],
        OKActions=alarm['OKActions'],
        AlarmActions=alarm['AlarmActions'],
        InsufficientDataActions=alarm['InsufficientDataActions'],
        MetricName=alarm['MetricName'],
        Namespace=alarm['Namespace'],
        Statistic=alarm['Statistic'],
        Dimensions=alarm['Dimensions'],
        Period=alarm['Period'],
        EvaluationPeriods=alarm['EvaluationPeriods'],
        Threshold=new_alarm_threshold,
        ComparisonOperator=alarm['ComparisonOperator']
    )
    # update actually creates a new alarm because the name has changed, so
    # we have to manually delete the old one
    client.delete_alarms(AlarmNames=[alarm_name])


if __name__ == '__main__':
    new_alarm_threshold = None
    alarm_name, new_alarm_name = sys.argv[1:3]
    # if passing a new alarm threshold, pull it out as an INT
    if sys.argv[3:4]:
        new_alarm_threshold = int(sys.argv[3:4][0])
    rename_alarm(alarm_name, new_alarm_name, new_alarm_threshold)
