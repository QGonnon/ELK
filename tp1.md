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
    - city(suppliers)
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
  