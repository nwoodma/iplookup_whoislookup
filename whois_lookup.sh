#!/bin/bash
# Command: ./whois_lookup.sh [fileame]
# Description: Runs a whois search on all the IPs and filters whois results by company name.
# Prints output to a file with the following format: {subdomain:IP addr}

filename=$1
readarray -t iplist < $filename #Reads input file line by line into the subdomains[] array
printf '%s\n' "${ip_list[@]}" #Prints each element in the subdomains array on a newline

#Runs whois command on each IP to retrieve CIDR, NetRange, and Organization
for ip in "${iplist[@]}"
do
	#whois_search_OG=`whois $ip | grep -e "NetRange" -e "Organization" -e "CIDR" | sed 's/Organization//' | sed 's/NetRange://' | sed 's/CIDR//' | tr -d '\n' | tr -d "   "`
	whois_search=`whois $ip | grep -e "inetnum" -e 'route' | awk '!/routes/' |  sed 's/inetnum://' | sed 's/route//' | tr -d '\n' | tr -d "   "`
	whois_search2=`whois $ip | grep -m 1 "descr" | sed 's/descr://' | tr -d '\n' | tr -d "   "` 
	#whois_search=`whois $ip | grep -e "inetnum" -e "route" -e "owner" | sed 's/inetnum//' | sed 's/owner//' |  tr -d '\n' | tr -d "   "`
	#filtered_whois_results=`echo $whois_search | grep -e "Ecolab" -e "Nalco" #Filters whois search for only IPs associated w/ Ecolab and Nalco
	echo "$ip:$whois_search:$whois_search2" #Prints ip and whois results 
done
