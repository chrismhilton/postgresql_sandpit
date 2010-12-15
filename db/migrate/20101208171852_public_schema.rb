class PublicSchema < ActiveRecord::Migration
  def self.up

    create_table :clients do |t|
      t.string :name
      t.string :subdomain
      t.timestamps
    end  

    add_index "clients", "subdomain"
    
    create_table :users do |t|
      t.integer :client_id
      t.string :name
      t.string :email
      t.timestamps
    end

  end
  
  def self.down

    drop_table :clients
    drop_table :users

  end
end
