# Créer l'index pour les logs NGINX
curl -X PUT "localhost:9200/nginx-logs?pretty"
# Créer un script pour convertir les logs au format combiné en JSON
cat > convert_nginx_logs.sh << 'EOF'
#!/bin/bash
while read line; do
 if [[ $line =~ ^([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)\ -\ ([^\ ]+)\ \[([^]]+)\]\ \"([^\ ]+)\ ([^\ ]+)\ ([^"]+)\"\ ([0-9]+)\ ([0-9]+)\ \"([^"]+)\"\ \"([^"]+)\" ]]; then
 IP="${BASH_REMATCH[1]}"
 USER="${BASH_REMATCH[2]}"
 TIMESTAMP="${BASH_REMATCH[3]}"
 METHOD="${BASH_REMATCH[4]}"
 PATH="${BASH_REMATCH[5]}"
 PROTOCOL="${BASH_REMATCH[6]}"
 STATUS="${BASH_REMATCH[7]}"
 SIZE="${BASH_REMATCH[8]}"
 REFERER="${BASH_REMATCH[9]}"
 USER_AGENT="${BASH_REMATCH[10]}"

 ISO_TIMESTAMP=$(date -d "${TIMESTAMP}" -u +"%Y-%m-%dT%H:%M:%S.000Z"2>/dev/null || date -j -f "%d/%b/%Y:%H:%M:%S %z" "${TIMESTAMP}" "+%Y-%m-%dT%H:%M:%S.000Z" 2>/dev/null)

 echo "{\"index\":{\"_index\":\"nginx-logs\"}}"
 echo "{\"@timestamp\":\"${ISO_TIMESTAMP}\",\"client_ip\":\"${IP}\",\"user\":\"${USER}\",\"method\":\"${METHOD}\",\"path\":\"${PATH}\",\"protocol\":\"${PROTOCOL}\",\"response\":${STATUS},\"bytes\":${SIZE},\"referer\":\"${REFERER}\",\"user_agent\":\"${USER_AGENT}\"}"
 fi
done < "$1"
EOF
chmod +x convert_nginx_logs.sh
# Convertir les logs et les indexer dans Elasticsearch
./convert_nginx_logs.sh nginx_logs > nginx_logs_bulk.json
curl -H "Content-Type: application/x-ndjson" -X POST "localhost:9200/_bulk?pretty" --data-binary @nginx_logs_bulk.json