Partie 1:
1.1 Explorer la structure de la base de données Northwind
- Identifiez les clés primaires et étrangères:
    - categories: category_id
    - products: product_id
    - supliers: supplier_id
    - order_details: order_id, product_id
    - orders: order_id
    - customers: customer_id
    - customer_customer_demo: customer_id, customer_type_id
    - customer_demographics: customer_type_id
    - shippers: shipper_id
    - us_states: state_id
    - employees: employee_id
    - employee_territories: employee_id, territory_id
    - territories: territory_id
    - regions: region_id
  
1.2 Analysez les relations entre les tables:
- Identifiez les relations one-to-many et many-to-many
    - one-to-many:
      - categories -> products
      - suppliers -> products
      - customers -> orders
      - shippers -> orders
      - employees -> orders
      - regions -> territories
    - many-to-many:
      - customers <-> customer_demographics
      - employees <-> territories
      - products <-> orders

1.3 Analysez les cas d'usage typiques pour la recherche:
- Identifiez les champs de recherche les plus pertinents
  - produit, commandes, categories, suppliers, clients, détail des commandes

1.4 Définir les objectifs pour l'index Elasticsearch
- Déterminer les informations importantes à stocker dans chaque index
  - products:
    - product_name
    - category_name(categories)
    - company_name(suppliers)
    - contact_name(suppliers)
    - city(suppliers)
    - address(suppliers)
    - region(suppliers)
    - postal_code(suppliers)
    - country(suppliers)
    - phone(suppliers)
  - orders:
    - company_name(shippers)
    - phone(shippers)
    - ship_name
    - ship_address
    - ship_city
    - ship_region
    - ship_postal_code
    - ship_country
    - company_name(customers)
    - contact_name(customers)
    - city(customers)
    - region(customers)
    - postal_code(customers)
    - country(customers)
    - phone(customers)

Partie 2:
2.1 Déterminer quelles tables doivent être dénormalisées
- Identifier les données à embarquer dans les documents (par exemple : catégories dans produits)
  - produits: categories, suppliers
  - commandes: shippers, customers

2.2 Concevoir la structure des documents
- Produits: inclure les informations des catégories et fournisseurs
  ```json
  {
    "product":"",
    "category":"",
    "supplier":{
        "name":"",
        "contact":"",
        "city":"",
        "address":"",
        "region":"",
        "postal_code":"",
        "country":"",
        "phone":""
    }
  }
  ```
- Commandes: inclure les informations clients et les détails des produits commandés
  ```json
  {
    "shipper":"",
    "shipper_phone":"",
    "ship":{
        "name":"",
        "address":"",
        "city":"",
        "region":"",
        "postal_code":"",
        "country":"",
    },
    "customer":{
        "name":"",
        "contact":"",
        "city":"",
        "region":"",
        "postal_code":"",
        "country":"",
        "phone":""
    }
  }
  ```

2.3 Définir les types de données pour chaque champ
- Identifiez les types appropriés (text, keyword, date, numeric, etc.)
  - produit: 
    ```json
    {
      "product":"text",
      "category":"text",
      "supplier":{
        "name":"text",
        "contact":"text",
        "city":"text",
        "address":"text",
        "region":"text",
        "postal_code":"keyword",
        "country":"text",
        "phone":"text"
      }
    }
    ```

  - commandes: 
    ```json
    {
        "shipper":"text",
        "shipper_phone":"text",
        "ship":{
            "name":"text",
            "address":"text",
            "city":"text",
            "region":"text",
            "postal_code":"keyword",
            "country":"text"
        },
        "customer":{
            "name":"text",
            "contact":"text",
            "city":"text",
            "region":"text",
            "postal_code":"keyword",
            "country":"text",
            "phone":"text"
        }
    }
    ```
- Décidez quels champs doivent être analysés pour la recherche full-text
  - Produits: product, category, supplier.name, supplier.contact
  - Commandes: shipper, ship.name, customer.name, customer.contact 
  
2.4 Configurer les analyseurs appropriés
- Définir un analyseur personnalisé pour les noms des produits
    ```json
        "analysis": {
            "filter": {
                "my_stop": {
                    "type": "stop",
                    "stopwords": ["a", "an", "the", "and", "or"]
                },
                "french_stemmer": {
                    "type": "stemmer",
                    "language": "light_french"
                }
            },
            "analyzer": {
                "custom_product_analyzer": {
                    "type": "custom",
                    "tokenizer": "standard",
                    "filter": [
                        "lowercase",
                        "my_stop",
                        "french_stemmer"
                    ]
                }
            }
        }
    ```
- Configurer les options d'analyse appropriées pour les champs textuels
    ```json
        "analysis": {
            "filter": {
                "my_stop": {
                    "type": "stop",
                    "stopwords": ["a", "an", "the", "and", "or"]
                },
                "french_stemmer": {
                    "type": "stemmer",
                    "language": "light_french"
                }
            },
            "analyzer": {
                "custom_product_analyzer": {
                    "type": "custom",
                    "tokenizer": "standard",
                    "filter": [
                        "lowercase",
                        "my_stop",
                        "french_stemmer"
                    ]
                },
                "standard_analyzer": {
                    "type": "standard"
                }
            }
        }
    ```

2.5 Créer le mapping dans Elasticsearch
- Pour l'index "products"
    ```json
    {
        "mappings": {
            "properties": {
                "product": {
                    "type": "text",
                    "analyzer": "custom_product_analyzer"
                },
                "category": {
                    "type": "text",
                    "analyzer": "standard_analyzer"
                },
                "supplier": {
                    "properties": {
                        "name": {
                            "type": "text",
                            "analyzer": "standard_analyzer"
                        },
                        "contact": {
                            "type": "text",
                            "analyzer": "standard_analyzer"
                        },
                        "city": {
                            "type": "text",
                            "analyzer": "standard_analyzer"
                        },
                        "address": {
                            "type": "text",
                            "analyzer": "standard_analyzer"
                        },
                        "region": {
                            "type": "text",
                            "analyzer": "standard_analyzer"
                        },
                        "postal_code": {
                            "type": "keyword"
                        },
                        "country": {
                            "type": "text",
                            "analyzer": "standard_analyzer"
                        },
                        "phone": {
                            "type": "text",
                            "analyzer": "standard_analyzer"
                        }
                    }
                }
            }
        }
    }
    ```
- Pour l'index "orders"
    ```json
    {
        "mappings": {
            "properties": {
                "shipper": {
                    "type": "text",
                    "analyzer": "standard_analyzer"
                },
                "shipper_phone": {
                    "type": "text",
                    "analyzer": "standard_analyzer"
                },
                "ship": {
                    "properties": {
                        "name": {
                            "type": "text",
                            "analyzer": "standard_analyzer"
                        },
                        "address": {
                            "type": "text",
                            "analyzer": "standard_analyzer"
                        },
                        "city": {
                            "type": "text",
                            "analyzer": "standard_analyzer"
                        },
                        "region": {
                            "type": "text",
                            "analyzer": "standard_analyzer"
                        },
                        "postal_code": {
                            "type": "keyword"
                        },
                        "country": {
                            "type": "text",
                            "analyzer": "standard_analyzer"
                        }
                    }
                },
                "customer": {
                    "properties": {
                        "name": {
                            "type": "text",
                            "analyzer": "standard_analyzer"
                        },
                        "contact": {
                            "type": "text",
                            "analyzer": "standard_analyzer"
                        },
                        "city": {
                            "type": "text",
                            "analyzer": "standard_analyzer"
                        },
                        "region": {
                            "type": "text",
                            "analyzer": "standard_analyzer"
                        },
                        "postal_code": {
                            "type": "keyword"
                        },
                        "country": {
                            "type": "text",
                            "analyzer": "standard_analyzer"
                        },
                        "phone": {
                            "type": "text",
                            "analyzer": "standard_analyzer"
                        }
                    }
                }
            }
        }
    }
    ```

Partie 3 : Transformation et indexation des données
3.1 Écrire les requêtes SQL pour extraire les données avec leurs relations
 - Requête pour récupérer les produits avec leurs catégories et fournisseurs
    ```sql
    SELECT p.product_id, p.product_name, c.category_name, s.company_name, s.contact_name, s.city, s.address, s.region, s.postal_code, s.country, s.phone
    FROM products p
    JOIN categories c ON p.category_id = c.category_id
    JOIN suppliers s ON p.supplier_id = s.supplier_id;
    ```
 - Requête pour récupérer les commandes avec leurs clients et expéditeurs
    ```sql
    SELECT o.order_id, o.ship_name, o.ship_address, o.ship_city, o.ship_region, o.ship_postal_code, o.ship_country, s.company_name AS shipper_name, s.phone AS shipper_phone, c.company_name AS customer_name, c.contact_name AS customer_contact, c.city AS customer_city, c.region AS customer_region, c.postal_code AS customer_postal_code, c.country AS customer_country, c.phone AS customer_phone
    FROM orders o
    JOIN shippers s ON o.ship_via = s.shipper_id
    JOIN customers c ON o.customer_id = c.customer_id;
    ```