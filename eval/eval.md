1. a) Un index permet de stocker et d'organiser des documents pour l'analyse et la recherche. Un index est composé de documents, et un document possède des champs composé de différents types de données.

"mappings": {
    "properties": {
        "nom": {
            "type": "text",
            "analyzer": standard
        },
        "description": {
            "type": "text",
            "analyzer": standard
        },
            "prix": {
            "type": "float"
        },
        "categories": {
            "type": "keyword"
        },
        "marque": {
            "type": "keyword"
        },
        "caracteristiques_techniques": { 
        "properties": {
            "poids": {
                "type": "float"
            },
            "dimensions": { 
                "type": "text"
            }
        }
        },
        "date_ajout": {
            "type": "date"
        },
        "mots_cles": {
            "type": "keyword",
            "analyzer": "simple"
        },
        "nombre_vues": {
            "type": "integer"
        },
        "note_moyenne": {
            "type": "float"
        }
    }
}

1. b) Les champs textuels sont de type "text" car ils contiennent des informations qui doivent être analysées pour la recherche, comme le nom et la description du produit. Le type "keyword" est utilisé pour les champs qui contiennent des valeurs exactes, comme les catégories et la marque, où l'analyse n'est pas nécessaire. Les champs numériques (float, integer) sont utilisés pour les prix, le poids et le nombre de vues, car ils nécessitent des opérations mathématiques. Le champ date est de type "date" pour stocker les dates d'ajout.

1. c) 
- L'autocomplétion dans la barre de recherche : Utiliser un analyzer "autocomplete" pour indexer les champs de texte, permettant une recherche rapide et efficace.
- La recherche full-text dans les descriptions : Utiliser un analyzer "standard" pour les descriptions, permettant une recherche textuelle complète.
- Le filtrage par catégories et par gamme de prix : Utiliser des champs de type "keyword" pour les catégories et des champs numériques pour les prix, permettant des filtres rapides et efficaces.

2. a) 
```
┌────────────┐ ┌───────────────┐ ┌────────────┐
│ Web        │ │ Mobile Backend│ │   Database │
│ Server     │ │     Server    │ │            │
└─────┬──────┘ └───────┬───────┘ └──────┬─────┘
      │                │                │
      └────────────────┼────────────────┘
                       │
                 ┌─────▼─────┐
                 │ Filebeat  │
                 └─────┬─────┘
                       │
                       │
                 ┌─────▼─────┐
                 │ Logstash  │
                 └─────┬─────┘
                       │
                ┌──────▼──────┐
                │Elasticsearch│
                └──────┬──────┘
                       │
                  ┌────▼────┐
                  │  Kibana │
                  └─────────┘
```

b)
```yml
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /logs/web/access.log
  json.keys_under_root: true
  json.add_error_key: true
  json.message_key: log
  tags: ["web", "json"]
  fields:
    source_type: web
  fields_under_root: true

filebeat.modules:
- module: apache
  access:
    enabled: true
    var.paths: ["/logs/apache/access.log"]
  error:
    enabled: true
    var.paths: ["/logs/apache/error.log"]
  
- module: postgresql
  log:
    enabled: true
    var.paths: ["/logs/postgres/*.log"]
  

processors:
- add_host_metadata: ~
- add_cloud_metadata: ~
- add_docker_metadata: ~
- add_fields:
    target: unified_log
    fields:
      version: 1.0.0

output.logstash:
  hosts: ["logstash:5044"]

logging.level: info
logging.to_files: true
logging.files:
  path: /var/log/filebeat
  name: filebeat
  keepfiles: 7
  permissions: 0644
```

c)
```conf
input { beats { port => 5044 } }

filter {
    # Add debug field to see raw values
    mutate {
        add_field => { "debug_event_module" => "%{[event][module]}" }
    }

    # Routing based on source type
    if [source_type] == "web" {
        mutate { add_field => { "service.type" => "web" } }
    } else if [event][module] == "postgres" {
        mutate { add_field => { "service.type" => "postgres" } }
    } else if [event][module] == "apache" {
        mutate { add_field => { "service.type" => "apache" } }
    }

    # Default service type if none matched
    if ![service.type] {
        mutate { add_field => { "service.type" => "unknown" } }
    }

    # Add unified fields
    mutate {
        add_field => {
            "event.category" => "web"
            "unified_log.version" => "1.0.0"
            "unified_log.timestamp" => "%{@timestamp}"
        }
    }

    # Add processing timestamp
    mutate {
        add_field => { "unified_log.processed_at" => "%{+YYYY-MM-dd}T%{+HH:mm:ss.SSS}Z" }
    }
}

output {
    elasticsearch {
        hosts => ["elasticsearch:9200"]
        index => "unified-logs-%{+YYYY.MM.dd}"
    }
    stdout { codec => rubydebug }
}
```

3. a)
```json
GET /produits/_search
{
  "query": {
    "bool": {
      "must": [
        {
          "term": {
            "marque": "Samsung"
          }
        },
        {
          "term": {
            "categories": "Smartphones"
          }
        },
        {
          "range": {
            "prix": {
              "gte": 300,
              "lte": 800
            }
          }
        }
      ]
    }
  },
  "sort": [
    {
      "note_moyenne": {
        "order": "desc"
      }
    }
  ]
}

```

b)
```json
GET /produits/_search
{
  "query": {
    "bool": {
      "must": {
        "multi_match": {
          "query": "appareil photo professionnel reflex photo",
          "fields": [
            "nom^3", 
            "description"
          ],
          "operator": "or"
        }
      }
    }
  }
}
```

4. a)
Visualisation du nombre de requêtes par minute:
- Type de visualisation: Graphique à lignes.
- Données sources: Logs du serveur backend.
- Métriques et dimensions: nombre de requêtes sur l'axe Y et le temps sur l'axe X.
- Utilité pour les opérations: Permet de surveiller l'instensité du trafic sur l'application en temps réel afin d'identifier des pics d'activité ou des périodes creuses.

Visualisation du taux de conversion:
- Type de visualisation: Diagramme de barres.
- Données sources: Logs d'événements de transactions.
- Métriques et dimensions: nombre d'achats réalisés sur l'axe Y et le nombre de visites sur l'axe X.
- Utilité pour les opérations: Permet de suivre les performances de vente et évaluer l'efficacité des campagnes marketing et de la conception du site.

Visualisation des erreurs HTTP:
- Type de visualisation: Pie.
- Données sources: Logs du serveur backend.
- Métriques et dimensions: nombre d'erreurs HTTP (codes 4xx et 5xx) par type.
- Utilité pour les opérations: Permet d'identifier rapidement les problèmes et les erreurs susceptibles d'affecter l'expérience utilisateur.

Visualisation des performances des requêtes de la base de données:
- Type de visualisation: Graphique à barres.
- Données sources: logs de temps d'exécution des requêtes de la base de données.
- Métriques et dimensions: moyenne des temps d'exécution des requêtes sur l'axe Y et le type de requête sur l'axe X.
- Utilité pour les opérations: Surveiller les performances de la base de données pour corriger les problèmes de lenteur et optimiser les requêtes.

Visualisation de l'utilisation des ressources du serveur:
- Type de visualisation: Gauge.
- Données sources: logs de monitoring des serveurs.
- Métriques et dimensions: pourcentage d'utilisation de la CPU, de la mémoire et du disque.
- Utilité pour les opérations: Permet de vérifier la santé et la charge des serveurs hébergeant l'application, et éviter les surcharges.

Visualisation des transactions par région géographique:
- Type de visualisation: Carte.
- Données sources: Logs d'événements de transactions enrichis de données géographiques.
- Métriques et dimensions: Somme des transactions en fonction de la localisation géographique des utilisateurs.
- Utilité pour les opérations: Identifier les régions géographiques avec les meilleures performances de vente et potentiellement cibler des campagnes de marketing localisées.

4. b)
Module system: cpu, memory, disk, et network pour surveiller la santé des serveurs hébergeant l'application e-commerce.
Module apache: status pour surveiller les performances du serveur web et identifier les erreurs.
Module postgresql : status pour surveiller les performances de la base de données et identifier les problèmes de lenteur.
Module docker : containers pour surveiller l'utilisation des ressources au niveau des conteneurs Docker exécutant l'application pour éviter les problèmes de performance.