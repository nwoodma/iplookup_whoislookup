#!/bin/bash
# Command: ./iplookup.sh [fileame]
# Description: Runs dig command to resolve subdomains to IP(s) provided by the a file selected
# by the user. Then, runs a whois search on all the IPs and filters whois results by company name.
# Prints output to a file with the following format: {subdomain:IP addr}

filename=$1
readarray -t subdomains < $filename #Reads input file line by line into the subdomains[] array
#printf '%s\n' "${subdomains[@]}" #Prints each element in the subdomains array on a newline

#Runs dig command on each subdomain in the subdomains[] array
for host in "${subdomains[@]}"
do
	ip_addr=`dig $host +short | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}'` #| grep -E "^[^^][0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}"`
	ip_list=`echo $ip_addr | sed '$!s/$/,/' | tr -d '\n'`
	#echo "$ip_addr" #Testing
	#print_host_ips=`echo "$host:$ip_list"` #Test {subdomain:IP(s)} format
	
	ips_array=($(echo $ip_addr)) #Creates an domain_ips array with all of the ips found from dig
	#printf '%s\n' "${ips_array[@]}" #Prints each element in the domain_ips array
	
	#Runs whois command on each IP to retrieve CIDR, NetRange, and Organization
	for ip in "${ips_array[@]}"
	do
		#echo "$host:$ip" #Prints {subdomain:IP}
		whois_search=`whois $ip | grep -e "NetRange" -e "Organization" -e "CIDR" | sed 's/Organization//' | sed 's/NetRange://' | sed 's/CIDR//' |  tr -d '\n' | tr -d "   "`
		#filtered_whois_results=`echo $whois_search | grep -e "Ecolab" -e "Nalco"`
		#if  [[ $filtered_whois_results = "Ecolab" || $filtered_whois_results = "Nalco" ]]
		#then
		#cidr=`echo $filtered_whois_results | grep -E "^[^^][0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}"`
		#echo -e "$host:$ip\n$filtered_whois_results"
		#echo "$host:$cidr"
		echo -e "$host:$ip:$whois_search"
		#else
			#echo "Outside of Domain - $host:$ip"
		#fi
	done
done

