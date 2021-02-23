#!/usr/local/bin/python3
######################################################################################################################
# Purpose:      Generate rules report of all the security groups 	   		                             #
# Input Params: None  [Make sure to set AWS CLI session by populating env. vars. with keys.]                         #
# Usage:        ./ec2_sg_rules.py  > account-date.csv   [python ./ec2_sg_rules.py > gill-dev-sg-2018-04-11.csv]      #
# Author:       Abdul Gill	https://gist.github.com/amgill/353225152495d2dce52501fa70c2528a							                              #
# Doc. Ref:	http://boto3.readthedocs.io/en/latest/reference/services/ec2.html#EC2.Client.describe_security_groups#
######################################################################################################################
# UPDATES: 2021-02-22
# - added main() and turned into a function get_sg_rules so I could run through multiple instances and accounts
# - edited output so it listed every field in every line instead of line blocks under a name/id
# - added acct_num input from cli arg and the acct_num and region to the output
######################################################################################################################
# BASH SCRIPT:



######################################################################################################################

from __future__ import print_function

import sys
import json
import boto3

#Explicitly declaring variables here grants them global scope
cidr_block = ""
ip_protpcol = ""
from_port = ""
to_port = ""
from_source = ""


def get_sg_rules(acct_num, region):
	ec2=boto3.client('ec2', region )
	sgs = ec2.describe_security_groups()["SecurityGroups"]
	for sg in sgs:
		group_name = sg['GroupName']
		group_id = sg['GroupId']
#		print("%s,%s" % (group_name,group_id))
		# InBound permissions ##########################################
		inbound = sg['IpPermissions']
#		print("%s,%s,%s" % ("","","Inbound"))
		for rule in inbound:
			if rule['IpProtocol'] == "-1":
				traffic_type="All Trafic"
				ip_protpcol="All"
				to_port="All"
			else:
				ip_protpcol = rule['IpProtocol']
				from_port=rule['FromPort']
				to_port=rule['ToPort']
				#If ICMP, report "N/A" for port #
				if to_port == -1:
					to_port = "N/A"

			#Is source/target an IP v4?
			if len(rule['IpRanges']) > 0:
				for ip_range in rule['IpRanges']:
					cidr_block = ip_range['CidrIp']
					print("%s,%s,%s,%s,%s,%s,%s,%s" % (acct_num, region, group_name, group_id, "Inbound", ip_protpcol, to_port, cidr_block))

			#Is source/target an IP v6?
			if len(rule['Ipv6Ranges']) > 0:
				for ip_range in rule['Ipv6Ranges']:
					cidr_block = ip_range['CidrIpv6']
					print("%s,%s,%s,%s,%s,%s,%s,%s" % (acct_num, region, group_name, group_id, "Inbound", ip_protpcol, to_port, cidr_block))

			#Is source/target a security group?
			if len(rule['UserIdGroupPairs']) > 0:
				for source in rule['UserIdGroupPairs']:
					from_source = source['GroupId']
					print("%s,%s,%s,%s,%s,%s,%s,%s" % (acct_num, region, group_name, group_id, "Inbound", ip_protpcol, to_port, from_source))

		# OutBound permissions ##########################################
		outbound = sg['IpPermissionsEgress']
#		print("%s,%s,%s" % ("","","Outbound"))
		for rule in outbound:
			if rule['IpProtocol'] == "-1":
				traffic_type="All Trafic"
				ip_protpcol="All"
				to_port="All"
			else:
				ip_protpcol = rule['IpProtocol']
				from_port=rule['FromPort']
				to_port=rule['ToPort']
				#If ICMP, report "N/A" for port #
				if to_port == -1:
					to_port = "N/A"

			#Is source/target an IP v4?
			if len(rule['IpRanges']) > 0:
				for ip_range in rule['IpRanges']:
					cidr_block = ip_range['CidrIp']
					print("%s,%s,%s,%s,%s,%s,%s,%s" % (acct_num, region, group_name, group_id, "Outbound", ip_protpcol, to_port, cidr_block))

			#Is source/target an IP v6?
			if len(rule['Ipv6Ranges']) > 0:
				for ip_range in rule['Ipv6Ranges']:
					cidr_block = ip_range['CidrIpv6']
					print("%s,%s,%s,%s,%s,%s,%s,%s" % (acct_num, region, group_name, group_id, "Outbound", ip_protpcol, to_port, cidr_block))

			#Is source/target a security group?
			if len(rule['UserIdGroupPairs']) > 0:
				for source in rule['UserIdGroupPairs']:
					from_source = source['GroupId']
					print("%s,%s,%s,%s,%s,%s,%s,%s" % (acct_num, region, group_name, group_id, "Outbound", ip_protpcol, to_port, from_source))


def main():
	#print("%s,%s,%s,%s,%s,%s,%s,%s" % ("Account","Region","Group-Name","Group-ID","In/Out","Protocol","Port","Source/Destination"))

	# get the avail regions list
	region_list = [region['RegionName'] for region in boto3.client('ec2', 'us-east-1').describe_regions()['Regions']]

	# determine if account number is present
	if len(sys.argv) > 1:
		acct_num = sys.argv[1]
	else:
		acct_num = ''

	# build the output
	for region in region_list:
		get_sg_rules(acct_num, region)

main()
