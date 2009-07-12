require 'active_record'
require 'sqlite3'

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database  => "tmp_sqlite_file"
)

ActiveRecord::Migration::create_table :doors do |t|
  t.integer :state
end


Given /^I have declared a new ActiveRecord model Door$/ do
  class Door < ActiveRecord::Base
    include SSM
  end
end

Given /^I have added an index based property I will use to manage persistence with ActiveRecord$/ do
  class Door < ActiveRecord::Base
    ssm_property :state, :use_index
  end
end

And /^I save the instance of door$/ do
  @door.save
end

When /^I load the instance of Door$/ do
  @door = Door.find(@door.id)
end

Then /^the instance of Door should save$/ do
  @door.save
end

Then /^the state should persist when reloaded$/ do
  @door.reload
  @door.is?(:opened).should be_true
end

Then /^the state should persist when loading from scratch$/ do
  @door.is?(:opened).should be_true
end