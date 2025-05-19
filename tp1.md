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

