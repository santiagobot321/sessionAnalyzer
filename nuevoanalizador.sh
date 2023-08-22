#!/bin/bash

greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

auth_log_file="auth_logs.txt"

# Inicializar matrices asociativas
declare -A ip_counts
declare -A usernames

# Inicializar contadores
success_count=0
failed_count=0

# Leer y procesar el archivo de registros
while read -r timestamp time ip username status; do
    echo -e "\n${blueColour}Leyendo registro:${endColour} $timestamp - $ip - $username - $status"
    if [ "$status" == "Success" ]; then
        ((success_count++))
    elif [ "$status" == "Failed" ]; then
        ((failed_count++))
        ((ip_counts["$ip"]++))
        usernames["$username"]=1
    fi
done < <(awk '{print $1, $2, $3, $4, $5}' "$auth_log_file")

# Imprimir resultados intermedios
echo -e "\n${blueColour}Número total de intentos exitosos:${endColour} ${greenColour}$success_count${endColour}"
echo -e "\n${blueColour}Número total de intentos fallidos:${endColour} ${redColour}$failed_count${endColour}"

# Imprimir matrices asociativas
echo -e "\n${blueColour}IP Counts:${endColour}"

for ip in "${!ip_counts[@]}"; do
    if [[ "${ip_counts["$ip"]}" > 2 ]]; then
      echo -e "$ip: ${ip_counts["$ip"]} ${redColour}Suspect${endColour}"
    else
      echo -e "$ip: ${ip_counts["$ip"]} ${greenColour}Ok${endColour}"
    fi
done

echo -e "\n${blueColour}Usernames: ${endColour}"
for username in "${!usernames[@]}"; do
    echo "$username"
done
