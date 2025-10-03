#!/bin/bash

R="\033[0;31m"
G="\033[0;32m"
B="\e[0;34m"
N="\033[0m"

LOG=easyscan\ files/log.txt
RESULT=easyscan\ files/result.txt
PORTS=easyscan\ files/ports.txt

exec &> >(tee >(sed $'s/\033[[][^A-Za-z]*m//g' > "${LOG}"))

if [ $# -eq 0 ]; then
	echo -e "${R}[!] ERROR: Please supply the file containing the targets.${N}"
	exit
fi

if [[ ! -e $1 || ! -r $1 ]]; then 
	echo -e "${R}[!] ERROR: Please supply an existing and readable file.${N}"
	exit
fi

printf "\nSTARTING THE SCAN...\n\n\n"

mkdir "easyscan files" > /dev/null 2>&1

RX='([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])'
while IFS= read -r IP; do
	if [[ $IP =~ ^$RX\.$RX\.$RX\.$RX$ || $IP =~ [a-z]+\.[a-z]+ ]]; then
		echo -e "[${G}+${N}] Scanning ${G}${IP}${N}..."
		nmap $IP -sS -T3 -v -p- --defeat-rst-ratelimit > "${RESULT}" 2>&1
		> "${PORTS}"
		if cat "${RESULT}" | grep "open port" > /dev/null; then
			cat "${RESULT}" | grep "open port" | grep -oP "[0-9]+(?=/)" >> "${PORTS}"
			NMAP=$(paste -sd, "${PORTS}")
			NMAP="-p${NMAP}"
			echo -e "[${B}*${N}] Performing an ${B}in-depth NMAP scan${N} of open ports..."
			nmap $IP -Pn -A -T3 "${NMAP}" --defeat-rst-ratelimit | awk 'NF'	
			while IFS2= read -r PORT; do
				case "${PORT}" in
					"21")
						echo -e "[${B}*${N}] Port ${B}21${N} is open. Checking if ${B}anonymous login${N} is enabled..."
						nmap -Pn -sV -sC -T3 -p21 --script=ftp-anon $IP | awk 'NF';;
					"22")
						echo -e "[${B}*${N}] Port ${B}22${N} is open. Searching for ${B}SSH issues${N}..."
						ssh-audit $IP | awk 'NF';;
					"23")
						echo -e "[${B}*${N}] Port ${B}23${N} is open. Enumerating ${B}Telnet${N}..."
						nmap -Pn -n -sV -T3 -p23 --script="*telnet* and safe" $IP | awk 'NF';;
					"80")
						echo -e "[${B}*${N}] Port ${B}80${N} is open. Consider analyzing the hosted ${B}HTTP${N} service.";;
					"443")
						echo -e "[${B}*${N}] Port ${B}443${N} is open. Searching for ${B}SSL/TLS issues${N}..."
						sslscan $IP | awk 'NF' | tail -n +4;;
					"445")
						echo -e "[${B}*${N}] Port ${B}445${N} is open. Searching for ${B}SMB issues${N}..."
						unbuffer nxc smb $IP;;
					"8080" | "8443")
						echo -e "[${B}*${N}] Ports ${B}8080${N} and/or ${B}8443${N} are open. Consider investigating them further.";;
					*)
						:;;
				esac
			done < "${PORTS}"
			printf "\n\n"
		else
			printf "[${R}-${N}] ${R}%s${N} has no open ports.\n\n\n" "$IP"
		fi
	else
		printf "[${R}-${N}] ${R}${IP}${N} is not a valid IP address/URL.\n\n\n"
	fi
done < $1

printf "${N}SCAN COMPLETED!\n"
