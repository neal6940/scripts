#!/bin/bash

DDI=977936; 
ACCT=532164495553; 
current_region=us-east-1
backup_vault=use1-60day-backup-vault
volume_arn=arn:aws:ec2:us-east-1:532164495553:volume/vol-03896b4ef2d7221eb

faws -r $DDI env -a $ACCT && eval "$(faws -r $DDI env -a $ACCT)"

# A script to delete Backup snapshots:

#snapshot_list=$(aws ec2 describe-snapshots --output text --region $current_region  --filters Name=volume-id,Values=$volume_id --query "Snapshots[?contains(Description, 'AWS Backup')].[SnapshotId]")
snapshot_list=$(aws backup list-recovery-points-by-backup-vault --output text --region $current_region --backup-vault-name $backup_vault --by-resource-arn $volume_arn --query "RecoveryPoints[].{arn:RecoveryPointArn}")
counter=1

echo VOLUME: $volume_arn

for snapshot_arn in ${snapshot_list[@]}
do
    echo $counter: $snapshot_arn
    aws backup delete-recovery-point --backup-vault-name $backup_vault --recovery-point-arn $snapshot_arn --region $current_region; 
    counter=$[$counter+1]
done