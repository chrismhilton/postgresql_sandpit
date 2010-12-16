# PostgreSQL Sandpit application

This Rails 3 application includes logic for managing PostgreSQL schemas in a multi-tenant
environment using subdomains. The database structure consists of shared models/tables that
are located in the 'public' schema and models/tables that are created for each client/customer
in their own 'subdomain' schema. When a new client is registered a new 'subdomain' schema is
created in the database and loaded with the relevant tables and indexes.

app\helpers\schema_helper.rb

The SchemaHelper module contains the methods used to create, load and access PostgreSQL schemas.

db\migrate

The migrations to create database objects in the subdomain schemas have been altered to that when run
they are executed against each subdomain schema that exists in the database.

lib\tasks\template_setup.rb

The rake task 'rake db:template_setup' performs the following:

 (1) creates the database (which in turn creates the standard 'public' schema)

 (2) creates a 'template' schema 

 (3) performs migrations to create tables in the 'public' and 'template' schemas

 (4) loads test data into the 'public' and 'template' schemas

db\schema_subdomain.rb

The schema_subdomain.rb file contains the structure of the subdomain schemas and is used
by the SchemaHelper create_and_load_subdomain_schema method to load the schema objects.

This file can be updated after adding and running further migrations by:

 (1) uncomment the schema_search_path line in the database.yml file

 (2) run the rake task 'rake db:schema:dump' which updates the schema.rb file content

 (3) copy the latest subdomain schema definitions out of the schema.rb file and into the schema_subdomain.rb file making sure that the version timestamp is updated and the create_table commands exclude ":force => true"

 (4) comment out the schema_search_path line in the database.yml file
