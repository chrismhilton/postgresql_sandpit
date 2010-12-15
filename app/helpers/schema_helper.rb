# Schema Helper module containing methods used to create, load and access PostgreSQL schemas
# 
# The following line is required in the ApplicationController in order to use the module in controller classes:
# include SchemaHelper 
#
module SchemaHelper
  
  # references:
  # http://aac2009.confreaks.com/06-feb-2009-14-30-writing-multi-tenant-applications-in-rails-guy-naor.html
  # http://stackoverflow.com/questions/2782758/creating-a-multi-tenant-application-using-postgresqls-schemas-and-rails
  # http://stackoverflow.com/questions/1970564/rails-migrations-for-postgresql-schemas
  # http://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/PostgreSQLAdapter.html#method-i-schema_search_path
  
  # adds a schema to the search path
  def self.add_schema_to_path(schema_name)
    conn = ActiveRecord::Base.connection
    conn.execute "SET search_path TO #{schema_name}, #{conn.schema_search_path}"
    # the line above does not change the connection's schema_search_path property value;
    # alternatively this method could execute the following command if the reset_search_path method is not required
    # conn.schema_search_path = "#{schema_name}, #{conn.schema_search_path}"
  end

  # resets the search path to the connection's default schema search path 
  def self.reset_search_path
    conn = ActiveRecord::Base.connection
    conn.execute "SET search_path TO #{conn.schema_search_path}"
  end
   
  # returns public and subdomain schema names, excluding system schemas
  def self.schemas
    conn = ActiveRecord::Base.connection
    schemas = conn.select_values("select nspname from pg_namespace where nspname != 'information_schema' AND nspname NOT LIKE 'pg%'")
    return schemas  
  end

  # returns subdomain schema names, excluding the public schema and system schemas
  def self.subdomain_schemas
    conn = ActiveRecord::Base.connection
    schemas = conn.select_values("select nspname from pg_namespace where nspname != 'public' AND nspname != 'information_schema' AND nspname NOT LIKE 'pg%'")
    return schemas  
  end
  
  # provides the ability to perform a code block whilst temporarily adding a schema to the search path
  # the connection's default schema search path is included in the search path 
  # to facilitate access to public schema tables such as "schema_migrations" 
  def self.with_schema(schema_name, &block)
    conn = ActiveRecord::Base.connection
    old_schema_search_path = conn.schema_search_path
    conn.schema_search_path = "#{schema_name}, #{old_schema_search_path}"
    begin
      yield
    ensure
      conn.schema_search_path = old_schema_search_path
    end
  end
      
  # creates a schema
  def self.create_schema(schema_name)
     conn = ActiveRecord::Base.connection
     schemas = conn.select_values("select * from pg_namespace where nspname != 'information_schema' AND nspname NOT LIKE 'pg%'")

     if schemas.include?(schema_name)
        tables = conn.tables
        Rails.logger.info "#{schema_name} exists already with these tables #{tables.inspect}"
     else
        Rails.logger.info "About to create #{schema_name}"
        conn.execute "create schema #{schema_name}"
     end
  end
  
  # creates a subdomain schema and loads the schema with tables etc.
  # based on the schema_subdomain.rb file
  def self.create_and_load_subdomain_schema(schema_name)
    file = "#{Rails.root}/db/schema_subdomain.rb"
    create_and_load_schema(schema_name, file)
  end
  
  # creates a schema and loads the schema with tables etc.
  # based on the specified file
  def self.create_and_load_schema(schema_name, file)
    conn = ActiveRecord::Base.connection

    create_schema(schema_name)

    if File.exists?(file)
       Rails.logger.info "About to load the schema file #{file}"
       with_schema(schema_name) do
         load(file)
       end
    else
       abort %{Schema file #{file} doesn't exist}
    end
  end  
  
  def self.create_and_migrate_schema(schema_name)
    conn = ActiveRecord::Base.connection

    create_schema(schema_name)

    # Save the old search path so we can set it back at the end of this method
    old_search_path = conn.schema_search_path

    # Tried to set the search path like in the methods above (from Guy Naor)
    # [METHOD 1]: conn.execute "SET search_path TO #{schema_name}"
    # But the connection itself seems to remember the old search path.
    # When Rails executes a schema it first asks if the table it will load in already exists and if :force => true.
    # If both true, it will drop the table and then load it.
    # The problem is that in the METHOD 1 way of setting things, ActiveRecord::Base.connection.schema_search_path still returns $user,public.
    # That means that when Rails tries to load the schema, and asks if the tables exist, it searches for these tables in the public schema.
    # See line 655 in Rails 2.3.5 activerecord/lib/active_record/connection_adapters/postgresql_adapter.rb
    # That's why I kept running into this error of the table existing when it didn't (in the newly created schema).
    # If used this way [METHOD 2], it works. ActiveRecord::Base.connection.schema_search_path returns the string we pass it.
    conn.schema_search_path = schema_name

    # Directly from databases.rake.
    # In Rails 2.3.5 databases.rake can be found in railties/lib/tasks/databases.rake
    file = "#{Rails.root}/db/schema.rb"
    if File.exists?(file)
       Rails.logger.info "About to load the schema #{file}"
       load(file)
    else
       abort %{#{file} doesn't exist yet. It's possible that you just ran a migration!}
    end

    Rails.logger.info "About to set search path back to #{old_search_path}."
    conn.schema_search_path = old_search_path
  end
  
 end