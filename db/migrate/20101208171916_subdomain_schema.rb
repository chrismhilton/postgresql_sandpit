class SubdomainSchema < ActiveRecord::Migration
  def self.up
    
    # only perform migration for subdomain schemas
    schemas = SchemaHelper.subdomain_schemas
    say "Schema list: #{schemas.inspect}"
    
    schemas.each do |schema|
      
      say "Migrating schema: #{schema}"
      
      SchemaHelper.with_schema(schema) do
    
        create_table :activities do |t|
          t.integer :user_id
          t.string :subject
          t.string :description
          t.timestamps
        end

        add_index "activities", "user_id"
    
        create_table :activity_notes do |t|
          t.integer :activity_id
          t.text :note
          t.timestamps
        end
      
      end
    end
    
  end

  def self.down

    # only perform migration for subdomain schemas
    schemas = SchemaHelper.subdomain_schemas
    say "Schema list: #{schemas.inspect}"
    
    schemas.each do |schema|
      
      say "Migrating schema: #{schema}"
      
      SchemaHelper.with_schema(schema) do
    
        drop_table :activities
        drop_table :activity_notes
      
      end
    end

  end

end
