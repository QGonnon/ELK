# Reponses TP

## Partie 1

Mise en place 
- Création du répertoire de travail
- Création du fichier Docker Compose (docker-compose.yml)
- Création des répertoires nécessaires pour les différentes configurations

## Partie 2

- Configuration d'Apache et du générateur de logs (apache/httpd.conf)
- apache/log-generator.sh
- Configuration de Nginx et du générateur de logs (nginx/nginx.conf)
- nginx/log-generator.sh
- Configuration du serveur web personnalisé avec logs JSON (custom-web/log-generator.sh)

## Partie 3

- filebeat/filebeat.yml

## Partie 4

- metricbeat/metricbeat.yml

## Partie 5

- logstash/config/logstash.yml
- logstash/pipeline/unified-logs.conf

## Partie 6

- Création d'une Ingest Pipeline dans Elasticsearch (setup/setup-ingest-pipeline.sh)
- docker-compose.yml
- Création du répertoire (mkdir -p setup) + script exécutable (chmod +x setup/setup-ingest-pipeline.sh)

## Partie 7

- Démarrer l'env (docker-compose up -d)
- Vérifier l'état via (docker-compose ps)
- Vérification de l'accès à Kibana sur un navigateur via http://localhost:5601

### N°1 a N°6 : SCREENSHOT

## Partie 8