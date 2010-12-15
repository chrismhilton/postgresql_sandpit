# This file contains the definition for the subdomain database schemas.
#
# The create_table blocks do not include ":force => true" so that the file
# can be used in SchemaHelper.create_and_load_subdomain_schema method. 
# If that statement is included, a command is issued to drop the tables
# which causes an error as they do not exist.
#
ActiveRecord::Schema.define(:version => 20101208171916) do

  create_table "activities", :force => true do |t|
    t.integer  "user_id"
    t.string   "subject"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["user_id"], :name => "index_activities_on_user_id"

  create_table "activity_notes", :force => true do |t|
    t.integer  "activity_id"
    t.text     "note"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end