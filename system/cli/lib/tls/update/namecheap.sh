#!/bin/bash

set -eu

# Usage: ./duckdns.sh <domain name>

DOMAIN=$1
TOKEN=$(cat $FLAP_DATA/system/data/domains/$DOMAIN/authentication.txt)
USERNAME=$(cat $FLAP_DATA/system/data/domains/$DOMAIN/username.txt)


echo "* [dns-update:namecheap] Updating namecheap DNS for $DOMAIN."


ip=$(manager ip external)

tld=$(echo $DOMAIN | sed s/[^.]*.//)
sld=$(echo $DOMAIN | sed s/\.$tld//)

dkim=$(cat $FLAP_DIR/opendkim/keys/$DOMAIN/mail.txt | tr "\n" " " | grep --only-matching --extended-regexp 'p=.+"' | tr '"\t' ' ' | sed 's/[[:space:]]//g')


echo "https://api.namecheap.com/xml.response
        ?apiuser=${USERNAME}
        &apikey=${TOKEN}
        &username=${USERNAME}

        &Command=namecheap.domains.dns.setHosts
        &ClientIp=$ip

        &SLD=$sld
        &TLD=$tld

        &RecordType1=A
        &HostName1=@
        &Address1=$ip
        &TTL1=100

        &RecordType2=TXT
        &HostName2=mail._domainkey
        &Address2='v=DKIM1; h=sha256; k=rsa;$dkim'
        &TTL2=3600

        &RecordType3=TXT
        &HostName3=@
        &Address3='v=spf1 a mx -all'
        &TTL3=3600

        &RecordType4=TXT
        &HostName4=_dmarc
        &Address4='v=DMARC1; p=none'
        &TTL4=3600

        &RecordType5=MX
        &HostName5=@
        &Address5='$DOMAIN'
        &MXPref5=10
        &TTL5=3600"
