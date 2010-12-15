# To use a module in a rake task it's necessary to both require the file and include the module (below)
require File.expand_path('app/helpers/schema_helper.rb')

namespace :db do
  
  include SchemaHelper
  
  desc 'Creates the database, a template schema, the public and template schema tables and loads template data'
  task :template_setup => :environment do
    
    puts 'Starting template setup'
    
    puts 'Creating database.'
    Rake::Task["db:create"].invoke
    
    puts 'Creating template schema'
    SchemaHelper.create_schema('template')
    
    schemas = ActiveRecord::Base.connection.select_values("select * from pg_namespace where nspname != 'information_schema' AND nspname NOT LIKE 'pg%'")
    puts "These schemas exist in the database: #{schemas.inspect}"
    
    puts 'Creating public and template schema tables.'
    Rake::Task["db:migrate"].invoke

    puts 'Loading template data.'
    SchemaHelper.add_schema_to_path('template')
    client = Client.create(:name => 'Template', :subdomain => 'template')
    user = User.create(:name => 'Template', :email => 'user@template.com', :client => client)
    activity = Activity.create(:subject => 'Template activity', :description => 'Template activity description', :user => user)
    note = ActivityNote.create(:note => 'Template activity note', :activity => activity)
    SchemaHelper.reset_search_path
    
    puts 'Completed template setup'
  end
end
