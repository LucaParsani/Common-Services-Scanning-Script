#!/bin/bash

RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\e[0;34m"
NOCOLOR="\033[0m"
WHITE='\e[1;37m'

LOG=easyscan\ files/log.txt
RESULT=easyscan\ files/result.txt
PORTS=easyscan\ files/ports.txt

exec &> >(tee >(sed $'s/\033[[][^A-Za-z]*m//g' > "${LOG}"))

if [ $# -eq 0 ]; then
	echo -e "${RED}[!] ERROR: Please supply the file containing the targets.${NOCOLOR}"
	exit
fi

if [[ ! -e $1 || ! -r $1 ]]; then 
	echo -e "${RED}[!] ERROR: Please supply an existing and readable file.${NOCOLOR}"
	exit
fi

echo ""
echo ""
echo 'STARTING THE SCAN...'
echo ""
echo ""

mkdir "easyscan files" > /dev/null 2>&1

RX='([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])'
while IFS= read -r IP; do
	if [[ $IP =~ ^$RX\.$RX\.$RX\.$RX$ || $IP =~ [a-z]+\.[a-z]+ ]]; then
		echo -e "[${GREEN}+${NOCOLOR}] Scanning ${GREEN}${IP}${NOCOLOR}..."
		nmap $IP -sS -T3 -v -p- --defeat-rst-ratelimit > "${RESULT}" 2>&1
		> "${PORTS}"
		if cat "${RESULT}" | grep "open port" > /dev/null; then
			cat "${RESULT}" | grep "open port" | grep -oP "[0-9]+(?=/)" >> "${PORTS}"
			NMAP=$(paste -sd, "${PORTS}")
			NMAP="-p${NMAP}"
			echo -e "[${BLUE}*${NOCOLOR}] Performing an ${BLUE}in-depth NMAP scan${NOCOLOR} of open ports..."
			nmap $IP -Pn -A -T3 "${NMAP}" --defeat-rst-ratelimit | awk 'NF'	
			while IFS2= read -r PORT; do
				case "${PORT}" in
					"21")
						echo -e "[${BLUE}*${NOCOLOR}] Port ${BLUE}21${NOCOLOR} is open. Checking if ${BLUE}anonymous login${NOCOLOR} is enabled..."
						nmap -Pn -sV -sC -T3 -p21 --script=ftp-anon $IP | awk 'NF';;
					"22")
						echo -e "[${BLUE}*${NOCOLOR}] Port ${BLUE}22${NOCOLOR} is open. Searching for ${BLUE}SSH issues${NOCOLOR}..."
						ssh-audit $IP | awk 'NF';;
					"23")
						echo -e "[${BLUE}*${NOCOLOR}] Port ${BLUE}23${NOCOLOR} is open. Enumerating ${BLUE}Telnet${NOCOLOR}..."
						nmap -Pn -n -sV -T3 -p23 --script="*telnet* and safe" $IP | awk 'NF';;
					"80")
						echo -e "[${BLUE}*${NOCOLOR}] Port ${BLUE}80${NOCOLOR} is open. Consider analyzing the hosted ${BLUE}HTTP${NOCOLOR} service.";;
					"443")
						echo -e "[${BLUE}*${NOCOLOR}] Port ${BLUE}443${NOCOLOR} is open. Searching for ${BLUE}SSL/TLS issues${NOCOLOR}..."
						sslscan $IP | awk 'NF' | tail -n +4;;
					"445")
						echo -e "[${BLUE}*${NOCOLOR}] Port ${BLUE}445${NOCOLOR} is open. Searching for ${BLUE}SMB issues${NOCOLOR}..."
						unbuffer nxc smb $IP;;
					"8080" | "8443")
						echo -e "[${BLUE}*${NOCOLOR}] Ports ${BLUE}8080${NOCOLOR} and/or ${BLUE}8443${NOCOLOR} are open. Consider investigating them further.";;
					*)
						:;;
				esac
			done < "${PORTS}"
			echo ""
			echo ""
		else
			echo -e "[${RED}-${NOCOLOR}] ${RED}${IP}${NOCOLOR} has no open ports."
			echo ""
			echo ""
		fi
	else
		echo -e "[${RED}-${NOCOLOR}] ${RED}${IP}${NOCOLOR} is not a valid IP address/URL."
		echo ""
		echo ""
	fi
done < $1

echo -e "${NOCOLOR}SCAN COMPLETED!"
echo ""
