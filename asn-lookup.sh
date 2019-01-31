#!/bin/bash

# Read domain name from command argument
domainName=$1

# If domain name was not provided, prompt for it.
if [ ! $domainName ]
then
  echo -n "Enter domain name and press [ENTER]: "
  read domainName
fi

# Lookup IP for the domain.
ipAddress=$(nslookup $domainName | awk 'FNR == 6 {print $2}')

# WHOIS lookup for IP.
whois=$(whois -h whois.cymru.com " -v $ipAddress")

# Find ASN for IP address.
asn=$(echo "$whois" | awk 'FNR == 2 {print "AS"$1}')

# If no ASN was found
if [ ! $asn ]
then
    printf "No ASN found. Please check domain spelling.\n"
    exit 1
fi

# Print the WHOIS info.
printf "$whois\n"

# Save CIDR blocks to file.
filename=$domainName-ip-blocks.txt
whois -h whois.radb.net -- "-i origin $asn" | awk '/^route:/ {print $2;}' | sort | uniq > $filename
printf "IPs for $domainName saved to $filename.\n"


exit
