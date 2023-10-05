{\rtf1\ansi\ansicpg1252\cocoartf2513
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww28600\viewh15480\viewkind0
\pard\tx566\tx1133\tx1700\tx2267\tx2834\tx3401\tx3968\tx4535\tx5102\tx5669\tx6236\tx6803\pardirnatural\partightenfactor0

\f0\fs24 \cf0 #!/bin/bash\
\
#### OBJECTIVE: check if one or more domain (or url) is reachable through one or more DNS server ####\
echo "Run: this program is going to check if the provided domain list is reachable through DNS server"\
echo -e "The program will create three outputfile: 1 containing the domains reached and with wich IP resolution \\n1 containing the domains NOT reached \\n1 containing the domains with NO answer\'94\
\
# Specify the path to your file containing domain names and saves total domains\
domains_file="domains_to_check.txt"\
tot_domains=$(wc -l < "$domains_file")\
\
# Specify the path to your file containing a list of DNS servers\
dns_servers_file="dns_servers.txt"\
tot_dns_servers=$(wc -l < "$dns_servers_file")\
\
# Specify the path to your outputfile containing a list of domains reached from one ore more DNS servers\
domains_reached_file="domains_reached.txt"\
\
# Specify the path to your outputfile containing a list of domains reached from one ore more DNS servers\
domains_NOT_reached_file="domains_NOT_reached.txt"\
\
# Specify the path to your outputfile containing a list of domains for which there was not an answer from the DNS servers\
domains_NO_answer_file="domains_NOanswer.txt"\
 \
# Check if the domains list file exists\
if [ ! -f "$domains_file" ] && [ ! -s "$domains_file" ]; then\
    echo "Domains list file is missing or empty."\
    exit 1\
fi\
\
# Check if the DNS server file exists\
if [ ! -f "$dns_servers_file" ] && [ ! -s "$dns_servers_file" ]; then\
    echo "DNS servers file is missing or empty."\
    exit 1\
fi\
\
# Check if the domains_reached_file exists (if yes reset, if not create)\
if [ -f "$domains_reached_file" ]; then\
    > "$domains_reached_file"\
	echo "The output domains_reached_file has been formatted"\
else\
	touch "$domains_reached_file"\
	echo "The output domains_reached_file has been created"\
fi\
\
# Check if the domains_reached_file exists (if yes reset, if not create)\
if [ -f "$domains_NOT_reached_file" ]; then\
    > "$domains_NOT_reached_file"\
	echo "The output domains_NOT_reached_file has been formatted"\
else\
	touch "$domains_NOT_reached_file"\
	echo "The output domains_NOT_reached_file has been created"\
fi\
\
# Check if the domains_NOanswer_file exists (if yes reset, if not create)\
if [ -f "$domains_NO_answer_file" ]; then\
    > "$domains_NO_answer_file"\
	echo "The output domains_NO_answer_file has been formatted"\
else\
	touch "$domains_NO_answer_file"\
	echo "The output domains_NO_answer_file has been created"\
fi\
\
# Delay function of x seconds\
delay() \{\
	sleep 1\
\}\
\
# Function to display the progress bar\
display_progress() \{\
    local current_step="$1"\
    local total_steps="$tot_domains"\
    local percentage=$((current_step * 100 / total_steps))\
    local progress_bar_length=$((current_step * 50 / total_steps))\
    local progress_bar=$(printf '=%.0s' $(seq 1 "$progress_bar_length"))\
    local spaces=$(printf ' %.0s' $(seq 1 $((50 - progress_bar_length))))\
    echo -ne "\\rProgress: [$progress_bar$spaces] $percentage%"\
\}\
\
# Initialiaze counter of domains (tot, tot non reachable, tot reachable, tot in error)\
counter=(0 0 0 0)\
\
# Initialize a counter for current step\
current_step=0\
\
# Loop through each domain in the domains_file and check if is in correct format\
for domain in $(cat "$domains_file"); do\
	if [[ "$domain" =~ ^[a-zA-Z0-9.-]+\\.[a-zA-Z]\{2,\}$ ]]; then\
		counter[0]=$((counter[0] + 1))\
		# Loop through each DNS Server in the dns_servers_file and check if is in correct format\
		for dns_server in $(cat "$dns_servers_file"); do\
			if [[ "$dns_server" =~ ^([0-9]\{1,3\}\\.)\{3\}[0-9]\{1,3\}$ ]]; then\
				ip=$(dig +short "@$dns_server" "$domain")\
				delay\
				# check if the resolution address is not null and different from known ip redirect\
				if [ -n "$ip" ] && [ "$ip" != "127.0.0.1" ] && [[ "$ip" != *"timed out"* ]]; then\
					echo "ATTENTION: $domain is reachable via DNS server $dns_server, IP: $ip"\
					echo "$domain is reachable via DNS server $dns_server, resolved IP: $ip" >> "$domains_reached_file"\
					counter[2]=$((counter[2] + 1))\
				# check if there is an error during the resolution\
				elif [[ "$ip" == *"timed out"* ]]; then\
					echo "ERROR: the DNS server $dns_server does NOT answer for $domain reachability: $ip"\
					echo "Error: the DNS server $dns_server does NOT answer for $domain reachability: $ip" >> "$domains_NO_answer_file"\
					counter[3]=$((counter[3] + 1))\
				else\
					echo "OK: $domain is NOT reachable via DNS server $dns_server"\
					echo "OK: $domain is NOT reachable via DNS server $dns_server" >> "$domains_NOT_reached_file"\
					counter[1]=$((counter[1] + 1))\
				fi\
			else\
				echo "DNS server is NOT in valid format: $dns_server"\
			fi\
		done\
		#delay\
		# Increment the current step counter\
		((current_step++))\
		# Display the current progress bar every 25 domains\
		if (("$current_step" % 25 == 0)); then \
			display_progress "$current_step" "$total_lines"\
			echo ""\
			echo -e "Current report --> ## TOT domains processed: $\{counter[0]\} ##\\n## TOT reached: $\{counter[2]\} ## TOT NOT reached: $\{counter[1]\} ## TOT error: $\{counter[3]\} ##"\
			echo ""\
        fi\
	else\
		echo "Domain is NOT in valid format: $domain"\
	fi\
done\
\
echo -e "## DONE: final report -->\\n## TOT domains processed: $\{counter[0]\} ##\\n## TOT reached: $\{counter[2]\} ## TOT NOT reached: $\{counter[1]\} ## TOT error: $\{counter[3]\} ##"\
echo -e "TOT domains in input: $tot_domains \\nTOT DNS servers in input: $tot_dns_servers"\
\
\
exit 0}