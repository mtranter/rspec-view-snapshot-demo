require 'spec_helper'
require 'rspec/snapshot'
require 'mysql2'

CREATE_TABLE_SQL = <<-SQL
CREATE TABLE IF NOT EXISTS source_data(
  id int NOT NULL AUTO_INCREMENT, 
  name varchar(200), 
  surname varchar(200), 
  PRIMARY KEY (id)
)
SQL

CREATE_VIEW_SQL = <<-SQL
CREATE OR REPLACE VIEW clean_data as 
SELECT id, name from source_data
SQL

RSpec.describe 'DB Snapshots' do
  describe 'the view matches the snapshot' do

    client = Mysql2::Client.new(:host => "db", :username => "user", :password => "password", :database => "db")

    before(:all) do
      client.query(CREATE_TABLE_SQL)      
      client.query(CREATE_VIEW_SQL)
    end
  
    it 'The view matches the snapshot' do
      view = client.query("select * from clean_data limit 1")
      headers = view.fields
      types = view.field_types
      view_def = Hash[headers.zip(types)]
      expect(view_def).to match_snapshot('clean_data.view')
    end
  end
end