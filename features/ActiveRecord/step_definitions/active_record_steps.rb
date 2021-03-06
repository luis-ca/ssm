require 'active_record'
require 'sqlite3'

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database  => "tmp_sqlite_file"
)

ActiveRecord::Migration::create_table :doors do |t|
  t.integer :state_idx
  t.string  :state_str
end

at_exit do
  File.delete("tmp_sqlite_file")
end

Given /^I have declared a new ActiveRecord model Door$/ do
  class Door < ActiveRecord::Base
    include SSM
  end
end

Given /^I have added an index based property I will use to manage persistence with ActiveRecord$/ do
  class Door < ActiveRecord::Base
    ssm_inject_state_into :state_idx, :as_integer => true, :strategy => :active_record
  end
end

Given /^I have added a string based property I will use to manage persistence with ActiveRecord$/ do
  class Door < ActiveRecord::Base
    ssm_inject_state_into :state_str, :strategy => :active_record
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