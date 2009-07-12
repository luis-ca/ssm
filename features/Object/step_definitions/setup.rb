Given /^I have declared a new Door class$/ do
  class Door
    include SSM
  end
end

Given /^I have added an initial state named closed$/ do
  class Door
    ssm_initial_state :closed
  end
end

Given /^I have added a state called opened$/ do
  class Door
    ssm_state :opened
  end
end

Given /^I have added an event named open_it$/ do
  class Door
    ssm_event :open_it, :from => [:closed], :to => :opened do
    end
  end
end

When /^I trigger the open event on an instance of Door$/ do
  @door = Door.new
  raise @door.inspect
  @door.open_it
end

Then /^the state of the instance of Door should be opened$/ do
  @door.is?(:opened)
end
